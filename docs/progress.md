# Progress dashboard

> 每次学习开始和结束都看这个文件。全仓唯一总进度面板，不追求自动化；先确保持续更新。

## Current focus

- **阶段**：Phase 1 — CUDA execution model / Vector Add 复盘
- **本周目标（最多 3 个）**：
  1. [x] 导入既有 Vector Add 代码（`dc00c7e`）；用户已确认历史 benchmark 尚未生成，后续通过本周实验采集。
  2. [x] 用统一命令完成 N=2^24 的 CPU reference correctness / warmup / 20 批 repeated timing，保留原始样本；其余测试覆盖见 lab。
  3. [x] 已在 LAB.md 保存规模、block size 和 ncu 证据分析：大 N 接近 DRAM 吞吐上限，小 N 固定开销占比较大；尚未拆分纯 launch 开销。
- **下一次打开仓库时只做这件事**：5 分钟复盘 `reports/PROFILING.md` 的指标表：为什么 block=1024 的 achieved occupancy 仅 51.03%，却可达到 94.67% DRAM throughput？通过后收尾 Vector Add，开始 Phase 2 stride=1/2 访存对照。已有报告不用重采；2% 收益的唯一原因仍未定位。
- **每周可投入时间**：`[10]` 小时
- **最近学习日期**：`2026-11-07`

## Stage status

| 阶段                            | 状态   | 证据链接                          | 下一步                                        |
| ------------------------------- | ------ | --------------------------------- | --------------------------------------------- |
| 0. Reproducible environment     | 进行中 | `notes/environment/envs`          | 已有 RTX 3070 / CUDA 13.3 快照和初始提交；补实际构建命令及编译器版本 |
| 1. CUDA execution / Vector Add  | 待复盘 | `labs/01_cuda-basics/vector_add/LAB.md` | 边界尺寸检查、memcheck、多批 benchmark、规模与 block 对照及 ncu 已有证据；下次独立解释报告后收尾 |
| 2. Memory access                | 未开始 | —                                 | Strided access / transpose                    |
| 3. Reduction / Scan             | 未开始 | —                                 | Sum reduction                                 |
| 4. GEMM                         | 未开始 | —                                 | Naive GEMM                                    |
| 5. LLM operators                | 未开始 | —                                 | RMSNorm / Softmax / RoPE                      |
| 6. Attention                    | 未开始 | —                                 | Naive attention                               |
| 7. MoE                          | 未开始 | —                                 | Routing 与 dispatch                           |
| 8. DeepSeek-specific mechanisms | 未开始 | —                                 | 固定目标论文/实现版本                         |
| 9. Engineering & transfer       | 未开始 | —                                 | 端到端复现与回归测试                          |

## Knowledge confidence

每月更新一次：`0 = 没接触`、`1 = 听过`、`2 = 能解释`、`3 = 能实现`、`4 = 能独立诊断和迁移`。

| Topic                               | Confidence (0-4) | Evidence / gap                                                                                              |
| ----------------------------------- | ---------------: | ----------------------------------------------------------------------------------------------------------- |
| Thread/block/warp & indexing        |                2 | 能推导 grid/尾部/warp 分歧及驻留限制；已有尺寸检查和 N=257 memcheck；完整独立实现能力尚未单独验收 |
| Global/shared/register & coalescing |                1 | 已推导连续、stride=2、偏移一个 FP32 分别触及 4/8/5 个 32 字节段；能区分连续与对齐，内存层次尚未系统学习 |
| Reduction / warp primitives         |                1 | `[0]`                                                                                                       |
| GEMM tiling / Tensor Core           |                1 | `[0]`                                                                                                       |
| Numerical tolerance / precision     |                1 | `[0]`                                                                                                       |
| Benchmarking / profiling            |                2 | 能解释 Event 同步、均值/中位数、有效带宽、Roofline 与 occupancy 非单调关系；已运行自动 benchmark 和 ncu，首次报告阅读待独立复盘 |
| LLM operator decomposition          |                2 | 有推理框架经验，kernel 级拆解待系统训练                                                                     |
| Attention / MoE / sparse patterns   |                1 | `[0]`                                                                                                       |

## Open questions (最多 5 个)

- [ ] 能否独立解释 occupancy 更低但 DRAM 吞吐更高的本次结果？
- [ ] 1024 相对 256 的约 2% 收益具体来自什么？当前证据尚不能唯一归因；不阻塞下一阶段。

## Recent wins

- `2026-11-07` — 完成索引/warp/驻留口头检查、N=257 memcheck、多批计时、规模与 block 对照、首次 ncu 采集；结课摘要见 `notes/sessions/2026-11-07-vector-add-resume.md` 顶部。
- `2026-11-07` — 完成初始化与既有代码导入，初始提交 `dc00c7e`；本地环境快照记录 RTX 3070 8192 MiB、CUDA Toolkit 13.3。

## Blockers

- 当前助手会话的 GPU 访问被 OS 阻止（见 `notes/environment/2026-11-07-session.md`）；用户本地已成功采集 GPU 信息，见 `notes/environment/envs`。需要运行的实验可在用户本地终端执行。
