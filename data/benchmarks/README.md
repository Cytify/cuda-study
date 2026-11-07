# Benchmark data

此目录存放可机读的原始结果。Markdown 用于解释结论；CSV 用于保存每次测量的数据点。不要只保存最佳值或截图。

## Vector Add 自动记录

在仓库根目录执行（需要本地 GPU 和 nvcc）：

```bash
python3 scripts/benchmark_vector_add.py --block-size 256
# 指定输入规模（默认 N=16777216）
python3 scripts/benchmark_vector_add.py --block-size 256 --n 257
```

脚本每次重新编译当前源码、运行一次，在保留终端输出的同时追加到
`data/benchmarks/vector_add_summary.csv`，原始输出保存在 `data/benchmarks/logs/`。
记录当前 commit、源码 SHA256、源码是否有未提交改动，以及能查询到的 GPU/编译器信息。
编译或运行失败不追加汇总。单次顺序运行此脚本，不要并发写同一个 CSV。

已有输出也可以导入一次：

```bash
python3 scripts/benchmark_vector_add.py --import-log path/to/output.txt
```

导入时，原始运行时间、环境、commit 留空；warmup 和 repeats 从新版输出读取，旧版输出没有则留空。不会拿当前机器信息冒充历史环境。
重复导入会追加重复记录。可用 `--output /tmp/vector_add_summary.csv` 指定其他输出文件。

当前程序预热 1 次，再测 20 批，每批 100 次。每个批次先计算总时间 / 100，
汇总的 `statistic=median_of_batch_means`，`latency_us` 为这 20 个均值的中位数，
有效带宽用该中位数计算。warmup、repeats 和批次数从输出读取；不会硬编码旧统计口径。
这不是单次 kernel 延迟分布，因此 `p95_latency_us` 留空。

每次新版运行还保存独立的 `*-vector-add_raw.csv`，字段为
`run_id,block_size,batch_id,repeats,avg_latency_us`，一行一个批次均值；汇总 notes 链接该文件。
批次样本和汇总毫秒值打印到小数点后 9 位；单位转为微秒写入 CSV。
脚本检查样本完整性、中位数与带宽是否匹配，拒绝零耗时等无效统计。
仍支持导入旧的单批 `Average time` 输出，标记为 `batch_mean`，不冒充多批中位数。
脚本根据当前 baseline 源码中的 D2H 拷贝位置记录检查范围；目前已移至计时结束后，检查最终输出。
导入旧输出时检查范围记为 unknown。PASS 不代表已通过所有随机或边界测试。

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
