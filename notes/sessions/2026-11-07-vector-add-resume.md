# Vector Add 学习恢复

## 结束时状态（下次优先读这里）

本次学习已结束。下文按学习过程保留，早期“待做”事项可能已在后文完成；以本节及 `docs/progress.md` 为最新状态。

### 已有证据的结论

1. 学习者能推导 grid 向上取整、尾部索引和 warp 内路径分歧，并区分连续访问与起点对齐。
2. 已实现随索引变化的小整数输入和 CPU reference、计时后 D2H、N=0 空操作；N=257 的 Compute Sanitizer memcheck 为 0 errors，未外推为所有输入均已验证。
3. 已建立 20 批、每批 100 次的 Event 计时与 CSV/原始样本自动保存。大 N 翻倍时耗时约翻倍；小 N 的固定开销占比较大，尚未把该开销拆成纯 launch、调度和执行部分。
4. block size 正反两轮对照表明：当前 N=2^24、RTX 3070 上，1024 相对 256 耗时降低约 2%；源码一致，结果见 LAB.md EXP-001，不能泛化为任意算子或规模。
5. ncu 报告：256/1024 的 DRAM throughput=93.91%/94.67%，实际 occupancy=82.66%/51.03%，支持当前大输入接近 DRAM 吞吐上限、最高 occupancy 并非必要。1024 小幅收益的唯一原因仍未定位。

### 当前产物与操作

- 总进度：`docs/progress.md`；实验及结果：`labs/01_cuda-basics/vector_add/LAB.md`。
- 自动 benchmark：`python3 scripts/benchmark_vector_add.py --block-size 256`，支持 `--n`。
- 自动 profiling：`bash scripts/profile_vector_add.sh 256` 或 `1024`；脚本已补 `--page details`。
- 正常性能结果在 `data/benchmarks/`；profiling 在 `reports/profiling/`；两份已有报告均已导出 `details.txt`，无需重采。
- ncu 操作、参数与指标表：`reports/PROFILING.md`。Windows 性能计数器权限已由用户解决。
- 编译日志中 sm_75 的 12 registers 不可当作实际 CC8.6 的资源值，ncu 报告的实际值是 16。尚未改变目标架构或重建基线。
- 学习偏好：kernel 实现、执行模型和性能解释由学习者练习；计时、统计、脚本、归档等辅助代码由 AI 直接处理，不展开非法命令行参数的防御性工程。

### 下次最先做的一件事（5 分钟）

打开 `reports/PROFILING.md` 的本次指标表，由学习者解释：为什么 1024 的 achieved occupancy 只有 51.03%，却能达到 94.67% DRAM throughput？这是自测，不要求先重跑程序。

若能解释，Vector Add 转入复盘，开始 Phase 2 的 stride=1 与 stride=2 访存对照。若希望继续定位 2% 收益，再针对性增加 SchedulerStats/MemoryWorkloadAnalysis，而不是盲目采 full 或重复同一 benchmark。

### 尚未解决或尚未验证

- 尚未唯一定位 1024 的小幅收益来源；最小后续对照是同一 N、源码下两种 block 的针对性 ncu section。
- 新输入六尺寸的完整输出尚未归档；随机浮点与通用容差尚未系统学习，不标记全部 correctness 完成。
- ncu 读报告已讲解，但尚未通过学习者独立解释检查，不将首次采集成功等同于掌握 profiling。

---

- 已检查 `docs/progress.md`、模板 lab 和 `../../../cuda-learning/vector_add.cu`。
- 代码证据：既有实现包含线程索引、边界保护、host/device 拷贝、CPU 结果检查、warmup、CUDA event 重复计时和有效带宽计算；这些不等于学习者已独立掌握。
- 未发现已保存的 benchmark 数据或真实 GPU/CUDA 环境快照，暂不作性能结论。
- 本次聚焦：grid 向上取整与尾部线程。既有代码使用 `(n + block_size + 1) / block_size`，需对照正确的向上取整公式检查。
- 待回答：N=1000、block_size=256 时，需要几个 block、启动几个线程、哪些索引被边界判断排除？N=1024 时，既有公式会产生什么结果？
- 下一步：根据回答确认索引理解，再修正既有公式并导入实验；尚未运行 GPU 实验。

## 索引检查反馈

- 学习者正确推导：N=1000、block_size=256 需要 4 个 block，共 1024 个线程，全局 idx=1000..1023 不访问数组。
- 学习者独立给出正确公式 `(n + block_size - 1) / block_size`。
- 待澄清：上述 idx 是全局索引，不是 block 内的 `threadIdx.x`；原公式在 N=1024 时得到 5 个 block，是多启动而非覆盖不足。由于 `idx < n`，此例多余线程不访问数组，但不能由此证明所有输入与 launch 均正确。
- 下一检查点：最后一个 block 内，哪些 `threadIdx.x` 有效？为何每个 block 的线程都必须执行全局索引边界判断？

## 尾部 warp 检查

- 学习者主动联系到 warp divergence；有效范围回答为 0..232，需修正为 0..231（768+232=1000，条件为严格小于）。
- 最后一个 block 前 7 个 warp 全部有效；最后一个 warp 的 threadIdx.x=224..255，其中 224..231 有效，232..255 无效。
- 本次澄清：不同线程的条件结果不会触发第二次 kernel launch；无效线程跳过受保护的访存语句。短 if 可能被编译为谓词指令，不能仅凭源码断言实际生成分支。
- 参考：https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/ （Branching and Divergence）。
- 下一小题：N=992、block_size=256 时，是否仍存在同一 warp 内条件真假混合？尚待学习者回答。

## Warp 分歧检查完成

- 学习者正确解释 N=992：最后一个 block 的前 7 个 warp 全部有效，最后一个 warp 全部无效，没有 warp 内路径分歧。
- 学习者正确解释奇偶 if/else：256 个线程组成的 8 个 warp 均有路径分歧，各有 16 个线程选择每条路径。
- 补充定义：两条路径不必都有计算指令；进入 if 和跳过 if 也可形成不同路径。源码路径分歧与实际编译为分支或谓词指令须区分。
- 下一步：用 FP32 Vector Add 比较同一 warp 内连续索引与 stride=2 索引的地址跨度，再解释合并访存。尚未运行 GPU 实验。

## 连续与跨步访存检查

- 学习者正确计算连续 FP32 的前四个起始地址为 0、4、8、12，stride=2 为 0、8、16、24。
- 已解释：32 个线程 stride=2 的实际首末字节跨度为 252 字节，而非 256；在从 0 开始对齐的 32 字节分段模型下，触及段范围为 256 字节。
- 学习者正确推导分段模型：连续读取触及 4 段，有效字节占比 100%；stride=2 触及 8 段，有效字节占比 50%。连续读取段编号应为 0..3，口述曾写成 0..4。
- 下一步：解释模型的边界——两倍段数不能直接推出 kernel 慢两倍；先检查改变起始偏移如何影响段数。上述为地址模型推导，尚无真实性能测量。

## 对齐与计时范围

- 学习者正确给出 `a[idx+1]` 首末线程读取区间 `[4,8)`、`[128,132)`，并区分连续与对齐；段数起初沿用 stride=2 的基数算成 9，经展开后确认是 5 段，已说明混淆来源。
- 学习者正确指出：kernel-only 计时不应加入 H2D/D2H 数据量，传输还涉及不同链路和资源。
- 术语校准：`12*N / kernel_seconds` 是按算子名义流量计算的有效带宽，不等同于实测 DRAM 带宽；端到端指标也不是显存、PCIe、主存带宽的直接相加。
- 下一检查点：N=2^24、kernel 时间 0.20 ms，计算十进制 GB/s；H2D/D2H 不在计时区间。不据此断言已达到硬件峰值。
- 学习者已正确列出换算式 `(12 * 2^24) / (0.2/1000) / 10^9`，结果为 1006.63296 GB/s；这是题设数据，不是真实 benchmark。
- 当前会话运行 `bash scripts/check_env.sh`：有 nvcc 13.3（V13.3.33），但 nvidia-smi 报告 GPU access blocked by the operating system；GPU 型号和驱动版本未确认，不能在本会话报告真实 GPU 性能。见环境记录。
- 下一步：辨认现有代码 CUDA Event 计时边界，解释重复 100 次时为何除以 100，以及 event 同步的作用。

## 初始化后重新对齐 repo

- 用户已完成 START_HERE 初始化勾选；核对到初始提交 `dc00c7e`、每周 10 小时、偏好单次 20～30 分钟，O1 标为进行中。
- 新增本地快照 `notes/environment/envs`：RTX 3070，8192 MiB；NVIDIA-SMI 610.57.01，KMD 610.88；Toolkit 13.3，V13.3.33。这与助手会话无法访问 GPU 的记录属于不同执行上下文，不互相覆盖。
- lab 的 vector_add.cu 已由模板换为既有实现：N 固定 2^24，argv[1] 为 block_size，1 次 warmup，100 次重复，总时间除以 100。correctness 读取的是计时循环之前拷回的结果。
- 原有 grid 公式问题仍在，尚未修改代码；参数校验、N 可配置、边界和随机测试、独立批次统计仍待补。
- 未找到真实历史 benchmark 输出：CSV 只有表头，LAB 实验栏尚为空。将总进度的“代码和 benchmark 已导入”拆清，避免误报已验证。
- 已同步 README 运行参数和总进度；下一步继续 Event 同步问题，再推进小步代码修正及真实实验。

## 同步与统计口径检查

- 用户澄清历史 benchmark 尚未生成，并非遗漏导入。
- 学习者正确解释 launch 对 host 异步，测量前需等待相关 GPU 工作完成；已区分等待 stop event 与等待 stream 此前任务完成。
- 学习者正确辨认批次总时间除以 100 为平均耗时，并正确给出示例五批平均值的中位数 0.20 ms。
- 统计建议：本 lab 预热后测 20 批，每批 100 次，以批次平均耗时的中位数为主要比较值，同时保留各批次原始值与均值。此为本实验选择，不是 CUDA 通用强制标准；不代表单次 kernel 延迟中位数。
- 中位数对少量极端样本更稳健，但不是完全不受异常影响；尾延迟问题不能只看中位数。
- 参考：https://nvidia.github.io/CompileIQ/v1.1/benchmarking.html （工具可提供 mean、median 等统计）；https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/ （CUDA Event 计时）。

## 第一批真实结果与自动记录

- 用户提供 N=16777216、block=256、grid=65536、平均 0.4985 ms、有效带宽 403.90 GB/s、PASS。这是单批平均值，不是 20 批中位数；环境和次数未由该输出直接确认。
- 已保存原始输出 `data/benchmarks/vector_add-first-result.txt` 并导入 `vector_add_summary.csv`，未知历史元数据留空。
- 新增 `scripts/benchmark_vector_add.py`：默认编译当前源码并运行，追加标准 CSV、归档原始输出；支持 `--import-log`，运行时记录 commit、源码 hash 和可查询环境。
- 已确认用户修正 grid 公式。nvcc 编译通过；导入追加、单位换算、未知元数据、重复样本拒绝、错误表头以及模拟运行成功/失败路径检查通过。未在助手会话运行 GPU benchmark。
- 下一步：在本地运行 `python3 scripts/benchmark_vector_add.py --block-size 256`，自动生成下一批记录；之后补边界验证和多批统计。
- 自动记录链路已由用户实跑并核对 CSV：498.5 us、403.86 GB/s、warmup=1、repeats=100、batch_mean；已记录 RTX 3070、Toolkit 13.3、源码 hash 和 dirty 标记。不是独立采集的 100 个延迟样本。
- 下一教学任务：学习者自行增加第二个位置参数 N（保留第一个参数 block_size），明确本轮只支持 N>0、合法 block_size；先运行 N=1/255/256/257/1000/1024 的 correctness。N=0 另行定义并在分配与 launch 前处理，不混入当前性能记录。

## 多批计时初版评审

- 用户已实现 20 批，每批 100 次，Event 在外部创建、逐批同步，D2H 在全部批次之后。
- 当前 `batch_avg_ms.push_back(total_ms)` 保存的是整批总毫秒数，约 49.8 ms，不是单次均值；应保存 `static_cast<double>(total_ms) / iters`。
- 循环中把 total_ms 重置为 0，结束后又用 total_ms / iters 汇总，导致最终 0 ms 和 inf GB/s。此汇总不是有效 benchmark，不能导入性能结论。
- 下一步：修正批次均值，再从 20 个均值的排序副本中取中间两个的平均值，报告 `Median batch-mean time`；自动记录脚本尚未适配多批输出，暂不使用。

## 测量辅助代码完成

- 用户明确授权 AI 直接处理测量相关代码，希望学习重点保持在 kernel，而非手写统计与记录设施。
- 已修复每批 total_ms / 100、偶数批数中位数、零值汇总导致的 inf，增加明确单位与测量元数据输出；D2H 保持在计时外。
- 自动脚本支持新版 20 批输出、样本完整性与汇总一致性检查，归档 20 个批次均值到独立 raw CSV，汇总标记 median_of_batch_means。旧单批输出仍支持导入。新增 --n 指定输入长度。
- nvcc 编译通过，N=0 空操作执行通过；使用临时合成样本验证中位数、单位换算、追加、原始样本落盘、旧版兼容和无效输出拒绝，未将合成样本写入真实 benchmark。真实多批 GPU 执行待用户本地完成。

## Roofline 理解检查

- 学习者主动给出算术强度与设备 FLOP/s ÷ 带宽比较的思路，已理解工作量相对数据流量的判断方法。
- 校准单位为 FLOP/byte；当前 FP32 标量加法应对照匹配的 FP32 普通计算路径，不能用 FP16/Tensor Core 峰值替代。峰值模型用于界定上界，不证明实测已饱和。
- 名义 intensity=1/12 FLOP/byte，下一步固定 block=256，仅改变 N，以规模实验检验大输入近似线性耗时与小输入固定开销；缓存会影响解释，暂不预设结论。
- 参考：https://docs.nvidia.com/nsight-compute/ProfilingGuide/ （Roofline Charts）。

## 驻留与 occupancy 检查

- 学习者正确解释 block 分配到 SM，驻留受线程数、block 数、shared memory、寄存器等资源限制；剩余 block 等待资源。
- 在假设每 SM 最多 1536 线程、16 blocks 且忽略其他资源的题目中，正确推导 block=256 时驻留 6 blocks/1536 threads，block=1024 时驻留 1 block/1024 threads。
- 已区分 block 分配、驻留 warp 与就绪 warp 的指令发射；理解 occupancy 高不必然更快，以及本次 1024 收益不能直接归因于并发提高。题设数值不代表 RTX 3070 的实测资源。
- 下一步：检查本地 profiling 工具可用性，读取当前 kernel 的寄存器使用量与实际 occupancy，验证 block size 对资源和调度的影响；暂不宣称 2% 收益的具体原因已确定。
- 已发现 ncu 2026.2.0 和 nsys，核对 LaunchStats/Occupancy/SpeedOfLight section 可用。新增 `scripts/profile_vector_add.sh`，负责编译、跳过 warmup、只采集一次 kernel 并归档。脚本语法与 ptxas verbose 编译检查通过；真实计数器采集待本地终端执行。操作说明见 `reports/PROFILING.md`。
