---
id: K001
name: Vector Add
phase: "Phase 1"
status: in_progress
priority: P0
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
---

# Kernel Lab — Vector Add

## 0. Learning contract

- **为什么学它**：掌握索引映射、边界保护、kernel launch、基本错误检查与性能测量；用一个简单算子练习建立可信实验的完整闭环。
- **完成定义**：能说明每个线程处理哪些元素，覆盖非整除输入，能复现 correctness 与 benchmark，并解释不同 N 下的性能行为。
- **关联知识**：thread/block/grid、global memory、coalescing、launch overhead、effective bandwidth。
- **Reference**：先用 CPU 逐元素加法作为 oracle。

## 1. Operator contract

- 输入：两个长度为 N 的连续 FP32 向量 A、B。
- 输出：长度 N 的 C，其中 C[i] = A[i] + B[i]。
- 边界：当 N 不是 blockDim.x 的倍数时，尾部线程不得越界；N=0 是否支持由 host API 决定并需明确。
- 数值语义：FP32 elementwise add；正常有限值可做 exact equality 测试，但一般浮点算子需采用合适容差。

## 2. Decomposition before coding

- 直观映射：`idx = blockIdx.x * blockDim.x + threadIdx.x`，若 `idx < N` 则处理一个元素。
- 每个元素理论读取 2 个 FP32、写回 1 个 FP32，名义流量为 12 bytes/element（忽略 cache、事务和其他开销）。
- 大输入时常受内存带宽限制；小输入时 launch / 固定开销可能占比较大，需要实验验证。

## 3. Correctness plan

- [x] CPU reference：逐元素比较 `h_a[i] + h_b[i]`，当前为可精确表示的小整数输入；已检查源码并编译，改动后的 GPU 结果待归档。
- [ ] N=1、N 小于 block size、N 非整除 block size、较大 N
- [ ] 输入包含正负值、零、随机值；如测试 NaN/Inf，明确比较语义
- [ ] 检查 kernel launch 和同步时的 CUDA error

## 4. Experiment log

### BASELINE-001 — 20 批正常计时

- 环境：CSV 记录 RTX 3070、驱动 610.88、Toolkit 13.3、`nvcc -O3 -std=c++17`。
- N=16777216，block=256，grid=65536；warmup=1，每批 100 次，20 批。
- 批次均值中位数 497.879047 us；有效带宽 404.368477 GB/s；最终输出逐元素 CPU reference 检查 PASS。
- 20 个批次均值的最小/最大为 497.558708 / 498.657265 us，极差约为中位数的 0.221%。这描述批次均值的稳定性，不是单次 kernel 延迟分布。
- 汇总 `data/benchmarks/vector_add_summary.csv`，时间戳 `2026-11-07T05:24:21.480444+00:00`；原始样本 `data/benchmarks/20261107T052421480444Z-vector-add_raw.csv`。
- 源码有未提交修改，SHA256=`b06aa620ee288642b394c957125ae65be4fd5ed87eab0739d9f563a4f1afd97f`。
- 本次建立可比较基线，尚未凭 profiling 证明 memory-bound，也未完成 block size 对照。下一步估算 arithmetic intensity，并在固定 block 下只改变 N 检查耗时随规模的变化。

### SCALE-001 — 固定 block=256，仅改变 N

已核对 CSV 最近四组，均为 20 批、每批 100 次的批次均值中位数，correctness PASS。

| N | Latency (us) | Effective bandwidth (GB/s) |
|---:|---:|---:|
| 1024 | 7.508000 | 1.636654 |
| 1048576 | 35.716801 | 352.296728 |
| 8388608 | 249.669924 | 403.185512 |
| 16777216 | 498.036003 | 404.241040 |

- 最大两组 N 翻倍，时间约 1.995 倍，名义有效带宽稳定在 403～404 GB/s，支持大输入的数据搬运受限假设，但未用硬件计数器证明显存饱和。
- 小输入支持固定开销占比较大的解释，不能把 7.508 us 全当作纯 CPU launch 时间。批量 Event 区间可能包含 kernel 间的提交空隙，且还有设备调度与执行开销。
- 下一步若要区分开销来源，可查看 Nsight Systems 的 CPU launch 与 GPU kernel 时间线；暂不把调度空隙当作加法指令执行时间。
- 参考：https://developer.nvidia.com/blog/cuda-graphs/ 。

### CHECK-001 — 正整数边界尺寸

用户本地运行 `/tmp/vector_add 256 N`，block_size 固定为 256，结果如下。
原始运行时间、构建命令和代码 hash 未随本组输出提供；仅作为当前代码的正确性检查记录。

| N | Grid size | Average time (ms) | Effective bandwidth (GB/s) | 检查结果 |
|---:|---:|---:|---:|---|
| 1 | 1 | 0.0076 | 0.00 | PASS |
| 255 | 1 | 0.0148 | 0.21 | PASS |
| 256 | 1 | 0.0135 | 0.23 | PASS |
| 257 | 2 | 0.0072 | 0.43 | PASS |
| 1000 | 4 | 0.0179 | 0.67 | PASS |
| 1024 | 4 | 0.0167 | 0.73 | PASS |

- grid 数量均符合向上取整预期；当前输入固定 A=1、B=2，检查 C=3。
- 当前 D2H 拷贝位于 warmup 之后、计时循环之前，因此 PASS 验证的是 warmup 结果，不是计时循环之后的结果。
- 此记录不证明没有越界访问，也不代表随机输入、N=0、非法参数已验证。不从这些单批小尺寸耗时推断性能趋势。
- 下一步：学习者将 D2H 拷贝移到计时结束之后、CPU 比较之前，保持其位于 Event 区间外，再复查。
- 后续复查：学习者已完成上述移动，源码检查和 nvcc 编译通过；该改动后的 GPU 运行结果尚未在对话中提供。下一步增加随索引变化的正负输入与逐元素 CPU reference。
- 输入与 reference 复查：A 为 `float(i % 17) - 8`，B 为 `float(i % 13) + 6`，检查逐元素 `h_a[i]+h_b[i]`；均为小整数，可精确比较。源码检查与编译通过；用户表示完成，尚未附这版六个尺寸的 GPU 输出。错误分支目前仅打印索引，实际值与 expected 待补。

### CHECK-002 — Compute Sanitizer 尾部内存检查

- 用户执行：`compute-sanitizer --tool memcheck /tmp/vector_add 256 257`。
- 输出：N=257、block=256、grid=2、Correctness: PASS、ERROR SUMMARY: 0 errors。
- 本次运行未报告非法内存访问；不外推为所有输入均无错误。工具下打印的 0.0656 ms、0.05 GB/s 不纳入正常性能 benchmark。
- 用户明确希望聚焦 CUDA kernel，暂不展开命令行健壮性工程；后续约定使用合法参数。
- 下一步：不带 sanitizer，以固定 N=2^24、block=256，测 20 批、每批 100 次，保留各批均值，再计算中位数。

### EXP-001 — Block size

- 日期：2026-11-07；源码 SHA256=`b06aa620ee288642b394c957125ae65be4fd5ed87eab0739d9f563a4f1afd97f`，四组一致；基于 dc00c7e 且源码有未提交修改。
- 学习者假设：当前并发可能足够，改变 block size 的性能差异不大；不将增大 block 直接等同于提高实际并发，也不预设显存已饱和。
- 变量：只改变 blockDim.x；N=16777216、预热 1 次、20 批、每批 100 次，kernel-only。

| Block size | Median batch-mean (us) | Effective bandwidth (GB/s) | 批次均值极差/中位数 |
|---:|---:|---:|---:|
| 128 | 497.049599 | 405.043264 | 0.214% |
| 256 | 498.114395 | 404.177422 | 0.163% |
| 512 | 497.254410 | 404.876434 | 0.170% |
| 1024 | 488.094730 | 412.474422 | 0.348% |

- 四组 correctness PASS。128/256/512 的中位数相差约 0.21%；1024 相对本轮 256 耗时降低约 2.01%，有小幅收益迹象。
- 各配置仅独立运行一次，执行顺序 128→256→512→1024。批次内稳定性不等于跨运行可复现性；温度、频率、运行顺序仍可能影响结果，不能据此宣称 1024 普遍最优。
- 下一步：反向顺序 1024→512→256→128 再运行一轮，检查 1024 的小幅优势能否复现；不凭当前数据归因于 occupancy。

#### 反向复测

同一源码 SHA256、N、编译参数和统计口径，全部 PASS。

| Block size | 正序中位耗时 (us) | 反序中位耗时 (us) |
|---:|---:|---:|
| 128 | 497.049599 | 496.988163 |
| 256 | 498.114395 | 497.995052 |
| 512 | 497.254410 | 497.310715 |
| 1024 | 488.094730 | 488.160324 |

- 1024 相对 256 的耗时下降分别为 2.012% 和 1.975%，顺序反转后仍复现。当前 GPU、源码、N 下有稳定的小幅收益证据；无需仅因验证流程反复追加同类测量。
- 尚未定位原因，不宣称实际驻留线程更多或显存已饱和。block 变大不改变每个 warp 连续访问 32 个 FP32 的地址模式，不能将收益直接归因为更好的合并访存。
- 下一学习点：区分总 block 数与同时驻留的 block/warp 数，解释调度与资源限制，再决定是否用 profiling 检验具体假设。

#### 首次 Nsight Compute 证据

- 用户已解决计数器权限，两份报告均采集成功，每次 7 replay passes。离线导出为各目录的 details.txt，读法和完整表格见 `reports/PROFILING.md`。
- 两组实际每线程均使用 16 registers，用户 static/dynamic shared memory 均为 0；驻留 block 上限由 warp 容量限制，分别为 6 / 1。
- 理论 occupancy=100% / 66.67%，实际=82.66% / 51.03%；DRAM Throughput=93.91% / 94.67%，Compute Throughput=10.56% / 10.64%。支持 DRAM 吞吐主导，更多驻留 warp 并非必要；尚不能唯一解释约 2% 收益。
- 采集脚本补充 `--page details`，使文本输出显示详细指标；原始二进制报告保留。

## 5. Exit checklist

- [ ] correctness / edge cases
- [ ] 记录真实环境和 commit
- [ ] warmup + 多次 CUDA event timing
- [ ] 记录 median latency 和 effective bandwidth
- [ ] 解释小输入与大输入的差异
- [ ] 能不看笔记解释 grid/block/index 与越界保护
