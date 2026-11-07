#!/usr/bin/env python3
"""Run the Vector Add baseline, or import its existing stdout, into benchmark CSV."""
import argparse
import csv
from datetime import datetime, timezone
import hashlib
import math
from pathlib import Path
import re
import subprocess
import statistics
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "labs/01_cuda-basics/vector_add/vector_add.cu"
DATA = ROOT / "data/benchmarks"


def capture(command):
    try:
        result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
        return result.stdout.strip() if result.returncode == 0 else ""
    except OSError:
        return ""


def parse_output(output):
    patterns = {
        "n": r"^N\s*=\s*(\d+)\s*$",
        "block": r"^Block size\s*=\s*(\d+)\s*$",
        "grid": r"^Grid size\s*=\s*(\d+)\s*$",
        "ms": r"^(?:Average time|Median batch-mean time)\s*=\s*([\d.eE+-]+)\s*ms\s*$",
        "bandwidth": r"^Effective bandwidth\s*=\s*([\d.eE+-]+)\s*GB/s\s*$",
        "correctness": r"^Correctness:\s*(PASS|FAIL)\s*$",
    }
    parsed = {}
    for key, pattern in patterns.items():
        matches = re.findall(pattern, output, re.MULTILINE)
        if len(matches) != 1:
            raise ValueError(f"Expected exactly one {key} result; import one run at a time")
        parsed[key] = matches[0]
    if any(int(parsed[key]) <= 0 for key in ("n", "block", "grid")):
        raise ValueError("N, block and grid must be positive")
    if not (0 < float(parsed["ms"]) < float("inf")):
        raise ValueError("Average time must be finite and positive")
    if not (0 <= float(parsed["bandwidth"]) < float("inf")):
        raise ValueError("Bandwidth must be finite and nonnegative")
    parsed["samples"] = []
    parsed["statistic"] = "batch_mean"
    parsed["batches"] = "1"
    parsed["warmup"] = parsed["repeats"] = ""
    if "Median batch-mean time" in output:
        for name in ("warmup", "repeats", "batches"):
            matches = re.findall(rf"^{name.capitalize()}\s*=\s*(\d+)\s*$", output, re.MULTILINE)
            if len(matches) != 1:
                raise ValueError(f"Missing or duplicate {name}")
            parsed[name] = matches[0]
        samples = re.findall(r"^Batch:\s*(\d+), Average time = ([\d.eE+-]+) ms\s*$", output, re.MULTILINE)
        count = int(parsed["batches"])
        if count < 1 or int(parsed["repeats"]) < 1 or [int(i) for i, _ in samples] != list(range(count)):
            raise ValueError("Incomplete or unordered batch samples")
        parsed["samples"] = [float(value) for _, value in samples]
        if not all(math.isfinite(value) and value > 0 for value in parsed["samples"]):
            raise ValueError("Batch means must be finite and positive")
        median = statistics.median(parsed["samples"])
        if not math.isclose(median, float(parsed["ms"]), rel_tol=1e-7, abs_tol=1e-9):
            raise ValueError("Reported median does not match raw batch means")
        expected_bandwidth = 12 * int(parsed["n"]) / (median * 1e6)
        if not math.isclose(expected_bandwidth, float(parsed["bandwidth"]), rel_tol=1e-6, abs_tol=1e-6):
            raise ValueError("Reported bandwidth does not match median time")
        parsed["statistic"] = "median_of_batch_means"
    return parsed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--block-size", type=int, default=256)
    parser.add_argument("--n", type=int, default=1 << 24, help="Positive element count for performance runs")
    parser.add_argument("--import-log", type=Path, help="Import an existing single-run output; no GPU required")
    parser.add_argument("--output", type=Path, default=DATA / "vector_add_summary.csv")
    args = parser.parse_args()
    if not 1 <= args.block_size <= 1024:
        parser.error("block size must be between 1 and 1024")
    if not 1 <= args.n <= 2147483647:
        parser.error("N must be positive and fit the current program's integer parser")

    fields = next(csv.reader((DATA / "benchmark-schema.csv").open()))
    row = dict.fromkeys(fields, "")
    now = datetime.now(timezone.utc)
    run_id = now.strftime("%Y%m%dT%H%M%S%fZ")
    notes = []
    if args.import_log:
        output = args.import_log.read_text()
        # Import time and current source/environment cannot establish original run metadata.
        notes.extend(["imported_at_utc=" + now.isoformat(),
                      "original_timestamp_environment_commit=unknown"])
    else:
        row["timestamp_utc"] = now.isoformat()
        row["commit"] = capture(["git", "rev-parse", "HEAD"])
        dirty = capture(["git", "status", "--porcelain", "--", str(SOURCE)])
        if dirty:
            notes.append("source_dirty=true")
        notes.append("source_sha256=" + hashlib.sha256(SOURCE.read_bytes()).hexdigest())
        gpu = capture(["nvidia-smi", "--query-gpu=name,driver_version", "--format=csv,noheader", "--id=0"])
        if gpu:
            info = next(csv.reader([gpu.splitlines()[0]], skipinitialspace=True))
            if len(info) == 2:
                row["gpu_name"], row["driver_version"] = info
        version = capture(["nvcc", "--version"])
        match = re.search(r"release\s+([\d.]+)", version)
        row["cuda_toolkit"] = match[1] if match else ""
        row["compiler"] = "nvcc"
        row["compiler_flags"] = "-O3 -std=c++17"
        with tempfile.TemporaryDirectory(prefix="vector-add-") as directory:
            binary = str(Path(directory) / "vector_add")
            subprocess.run(["nvcc", "-O3", "-std=c++17", str(SOURCE), "-o", binary], check=True, cwd=ROOT)
            result = subprocess.run([binary, str(args.block_size), str(args.n)], text=True, capture_output=True, cwd=ROOT)
            print(result.stdout, end="")
            if result.returncode:
                raise RuntimeError(f"Benchmark failed; no summary appended:\n{result.stderr}\n{result.stdout}")
            output = result.stdout

    parsed = parse_output(output)
    row.update(kernel="vector_add", variant="baseline_block" + parsed["block"],
               dtype="fp32", shape="N=" + parsed["n"], layout="contiguous",
               statistic=parsed["statistic"], latency_us=format(float(parsed["ms"]) * 1000, ".12g"),
               warmup=parsed["warmup"], repeats=parsed["repeats"],
               effective_bandwidth_gbs=parsed["bandwidth"], correctness=parsed["correctness"],
               measurement_scope="kernel-only")
    notes.extend(["batches=" + parsed["batches"], "grid_size=" + parsed["grid"],
                  "values_rounded_by_program=true"])
    if args.import_log:
        notes.append("correctness_scope=unknown")
    else:
        source_text = SOURCE.read_text()
        scope = ("post_timing_output" if source_text.find("cudaMemcpyDeviceToHost")
                 > source_text.find("cudaEventElapsedTime") else "pre_timing_warmup_output")
        notes.append("correctness_scope=" + scope)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    exists = args.output.exists() and args.output.stat().st_size > 0
    if exists:
        with args.output.open(newline="") as stream:
            if next(csv.reader(stream)) != fields:
                raise ValueError("Existing CSV header differs from benchmark-schema.csv")
    log_dir = args.output.parent / "logs"
    log_dir.mkdir(exist_ok=True)
    log_path = log_dir / f"{run_id}-vector-add.txt"
    log_path.write_text(output)
    notes.append("raw_log=" + log_path.relative_to(args.output.parent).as_posix())
    if parsed["samples"]:
        raw_path = args.output.parent / f"{run_id}-vector-add_raw.csv"
        with raw_path.open("w", newline="") as stream:
            writer = csv.writer(stream)
            writer.writerow(["run_id", "block_size", "batch_id", "repeats", "avg_latency_us"])
            for index, value in enumerate(parsed["samples"]):
                writer.writerow([run_id, parsed["block"], index, parsed["repeats"], format(value * 1000, ".12g")])
        notes.append("raw_file=" + raw_path.name)
    row["notes"] = ";".join(notes)
    with args.output.open("a", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        if not exists:
            writer.writeheader()
        writer.writerow(row)
    print(f"Saved: {args.output}")


if __name__ == "__main__":
    main()
