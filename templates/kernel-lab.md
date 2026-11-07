---
id: KXXX
name: "Kernel name"
phase: "Phase N"
status: not_started
priority: P1
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
---

# Kernel Lab — Kernel name

## 0. Learning contract

- **为什么学它**：它训练哪种可迁移的 CUDA 能力？
- **完成定义**：列出可检查的证据，不写“熟悉/掌握”这种不可验收用词。
- **关联知识**：
- **参考实现 / 一手资料**：链接、版本或 commit；说明为什么可信。

## 1. Operator contract

- 数学定义 / 伪代码：
- 输入 shape：
- 输出 shape：
- dtype / accumulation dtype：
- layout / stride / alignment：
- mask / boundary / empty input behavior：
- 数值语义（rounding、是否允许近似、atol/rtol）：
- 禁止假设：例如输入一定连续、N 一定为 block size 的倍数。

## 2. Decomposition before coding

- 最直观的 reference 算法：
- 工作量与主要 memory traffic 估算：
- 线程/warp/block 映射：
- 需要的同步与临时存储：
- 预计瓶颈：launch / bandwidth / compute / occupancy / irregular access / other
- 我当前的假设与证据：

## 3. Correctness plan

- Reference/oracle：
- Test matrix：小尺寸、非整除尺寸、边界值、随机值、极端值、不同 dtype（按语义选择）
- 容差与原因：
- CUDA API/kernel error check：
- race / out-of-bounds / uninitialized memory 风险：
- 通过条件：

## 4. Implementation ladder

| Variant | 目标 | 实现差异（一次一个主变量） | Correctness | Median latency | 结论 |
|---|---|---|---|---:|---|
| V0 reference | 语义基线 | CPU / framework / simple oracle | pending | — | — |
| V1 naive CUDA | 最简单正确实现 | | pending | — | — |
| V2 optimization A | 验证一个瓶颈假设 | | pending | — | — |
| V3 optimization B | 在 V2 基础上进一步优化 | | pending | — | — |
| Vbest local | 当前最好且可信的版本 | | pending | — | — |

## 5. Experiment log

### EXP-001 — Hypothesis

- **日期 / commit**：
- **问题**：
- **改变的唯一主要变量**：
- **为什么预期它有效**：
- **预期观察到的指标变化**：
- **反证条件**：
- **结果**：
- **解释**：
- **CSV / profiler artifact**：
- **决定**：保留 / 回滚 / 继续调查

## 6. Benchmark protocol

- GPU / compute capability：
- Driver / CUDA toolkit / compiler / flags：
- Input shape / dtype / layout：
- Baseline/reference version：
- Warmup 次数、测量次数、统计量：
- 计时范围：kernel-only / end-to-end；是否包含 allocation / copies / launch：
- 是否独占 GPU、时钟/功耗状态是否稳定：
- 使用工具：CUDA events / benchmark framework / Nsight Compute / Nsight Systems：
- 原始结果 CSV：`data/benchmarks/`

## 7. Performance reasoning

- 理论 bytes moved / FLOPs：
- Roofline / bandwidth / throughput 粗估：
- 实测 latency / bandwidth / TFLOP/s：
- Profiler evidence：
- 主要瓶颈与置信度：
- 还有哪一种解释尚未排除？

## 8. Compare with open-source best

- **实现 / commit / version**：
- **硬件相同吗**：
- **shape / dtype / layout 相同吗**：
- **语义、mask、精度和计时范围相同吗**：
- **测量方法是否一致**：
- **差距可能来自什么**：
- **公平比较结论**：

## 9. What I learned

- 我开始时误解了什么？
- 最重要的三个原理：
- 如果重新实现，我会先做什么？
- 哪个结论能迁移到下一个 kernel？
- 仍未掌握的问题：

## 10. Exit checklist

- [ ] 明确数学语义、shape、dtype、layout、边界条件
- [ ] reference 与 correctness tests 可复现
- [ ] 测试覆盖边界和非整除情况
- [ ] 完成至少一个 CUDA baseline
- [ ] 有可信的 benchmark 与环境记录
- [ ] 至少验证过一个优化假设（若该 lab 目标包含优化）
- [ ] 能解释 performance bottleneck，不只是报告数字
- [ ] 与开源实现的比较口径明确
- [ ] 更新总进度和下一项任务
