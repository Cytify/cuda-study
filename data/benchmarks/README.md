# Benchmark data

此目录存放可机读的原始结果。Markdown 用于解释结论；CSV 用于保存每次测量的数据点。不要只保存最佳值或截图。

## Schema

CSV header:

`timestamp_utc,kernel,variant,commit,gpu_name,compute_capability,driver_version,cuda_toolkit,compiler,compiler_flags,dtype,shape,layout,warmup,repeats,statistic,latency_us,p95_latency_us,reference_latency_us,speedup,effective_bandwidth_gbs,tflops,correctness,measurement_scope,notes`

规则：
- 一行代表一次 benchmark run 的一个 variant/shape/dtype 汇总；如果要保存每次重复的原始样本，另存 `*_raw.csv`。
- `timestamp_utc` 使用 ISO 8601 UTC 时间。
- `shape` 采用易读字符串，例如 `N=16777216` 或 `M=4096;N=4096;K=4096`；CSV 中包含分号时需按标准 CSV 引号规则写入。
- `measurement_scope` 写明 `kernel-only` 或 `end-to-end`，以及是否含 allocation/copy。
- `effective_bandwidth_gbs` 仅在合理定义 bytes moved 时填写；`tflops` 仅在 FLOP 定义清楚时填写。
- 同一张表里的结果只有在环境、shape、dtype、语义和计时范围可比时才做 speedup 比较。
- GPU unavailable、warmup/repeats unknown 或 correctness 未通过的结果可以记录，但不能当作优化结论。
