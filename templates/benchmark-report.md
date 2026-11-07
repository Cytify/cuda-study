# Benchmark analysis — Kernel / variant

## Question

本次 benchmark 要回答什么问题？

## Conditions

- GPU / compute capability：
- Driver / CUDA / compiler / flags：
- Shape / dtype / layout：
- Warmup / repeats / statistic：
- Timed region：
- Commit：
- GPU 是否被其他任务占用：

## Results

| Variant | Correctness | Median (us) | P95 (us) | Effective GB/s | TFLOP/s | Notes |
|---|---|---:|---:|---:|---:|---|
| reference | | | | | | |
| custom baseline | | | | | | |
| optimization | | | | | | |

## Interpretation

- 主要差异：
- 理论上预期什么：
- 实际观察到什么：
- 测量噪声 / confounders：
- 需要 profiler 证据吗？用什么指标：
- 当前结论的适用范围：

## Decision

- [ ] 保留优化
- [ ] 回滚
- [ ] 重测
- [ ] 进一步 profiling

理由：
