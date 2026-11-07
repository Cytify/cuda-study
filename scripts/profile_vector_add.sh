#!/usr/bin/env bash
# Profile one post-warmup invocation; keep profiling output separate from benchmarks.
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
block_size="${1:-256}"
element_count="${2:-16777216}"
cd "$repo_root"
mkdir -p reports/profiling
profile_dir="$(mktemp -d "$repo_root/reports/profiling/vector-add-block${block_size}-XXXXXX")"
binary_path="$(mktemp /tmp/cuda-study-profile-XXXXXX)"
trap 'rm -f "$binary_path"' EXIT

{
  date -u +%FT%TZ
  printf 'block_size=%s\nN=%s\nflags=-O3 -std=c++17\n' "$block_size" "$element_count"
  git rev-parse HEAD
  git status --short -- labs/01_cuda-basics/vector_add/vector_add.cu
  sha256sum labs/01_cuda-basics/vector_add/vector_add.cu
  nvcc --version
  ncu --version
} > "$profile_dir/environment.txt"

nvcc -O3 -std=c++17 -Xptxas=-v \
  labs/01_cuda-basics/vector_add/vector_add.cu -o "$binary_path" \
  2>&1 | tee "$profile_dir/build.txt"

printf 'Profiling output: %s\n' "$profile_dir"
# The first launch is warmup. Collect only the next invocation.
if ncu --section LaunchStats --section Occupancy --section SpeedOfLight \
    --launch-skip 1 --launch-count 1 \
    --page details \
    --export "$profile_dir/profile" --log-file "$profile_dir/ncu.txt" \
    "$binary_path" "$block_size" "$element_count" \
    2>&1 | tee "$profile_dir/program.txt"; then
  cat "$profile_dir/ncu.txt"
else
  if [[ -f "$profile_dir/ncu.txt" ]]; then
    cat "$profile_dir/ncu.txt"
  fi
  exit 1
fi
printf '\nSaved profiling reports: %s\n' "$profile_dir"
printf 'Use normal benchmark runs for latency comparisons; do not import these instrumented timings.\n'
