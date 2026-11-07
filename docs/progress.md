# Progress dashboard

> 每次学习开始和结束都看这个文件。全仓唯一总进度面板，不追求自动化；先确保持续更新。

## Current focus

- **阶段**：Phase 1 — CUDA execution model / Vector Add 复盘
- **本周目标（最多 3 个）**：
  1. [x] 把既有 Vector Add 代码和真实 benchmark 导入 `labs/01_cuda-basics/vector_add/`。
  2. [ ] 用统一命令重新跑 correctness / warmup / repeated timing。
  3. [ ] 写出“为什么这组规模的瓶颈可能是带宽/launch overhead”的证据分析。
- **下一次打开仓库时只做这件事**：复查 CUDA Event 重复计时边界与同步，再从可访问 GPU 的终端采集环境与真实 benchmark。有效带宽单位换算已通过；当前助手会话的 GPU 访问被 OS 阻止。
- **每周可投入时间**：`[10]` 小时
- **最近学习日期**：`2026-11-07`

## Stage status

| 阶段                            | 状态   | 证据链接                          | 下一步                                        |
| ------------------------------- | ------ | --------------------------------- | --------------------------------------------- |
| 0. Reproducible environment     | 进行中 | `notes/environment/`              | 记录真实软硬件版本与 build command            |
| 1. CUDA execution / Vector Add  | 进行中 | `labs/01_cuda-basics/vector_add/` | 导入已有实验，重新检查 correctness 和测量方法 |
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
| Thread/block/warp & indexing        |                2 | 2026-11-07：能推导 grid 向上取整，解释 N=992 的 warp 边界及奇偶分支；尾部索引曾有差一位，尚待代码验证       |
| Global/shared/register & coalescing |                1 | 已能推导对齐连续 FP32 与 stride=2 在 32 字节分段模型下分别触及 4/8 段；对齐偏移待检查，内存层次尚未系统学习 |
| Reduction / warp primitives         |                1 | `[0]`                                                                                                       |
| GEMM tiling / Tensor Core           |                1 | `[0]`                                                                                                       |
| Numerical tolerance / precision     |                1 | `[0]`                                                                                                       |
| Benchmarking / profiling            |                1 | `[0]`                                                                                                       |
| LLM operator decomposition          |                2 | 有推理框架经验，kernel 级拆解待系统训练                                                                     |
| Attention / MoE / sparse patterns   |                1 | `[0]`                                                                                                       |

## Open questions (最多 5 个)

- [ ] `[当前最影响下一步的问题]`

## Recent wins

- `2026-11-07` — 完成索引与 warp 路径分歧口头检查；见 `notes/sessions/2026-11-07-vector-add-resume.md`。尚无本次 GPU 实验结果。

## Blockers

- `[问题]`；已尝试：`[...]`；最小复现：`[...]`；下一步：`[...]`
