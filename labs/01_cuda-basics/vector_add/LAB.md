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

- [ ] CPU reference
- [ ] N=1、N 小于 block size、N 非整除 block size、较大 N
- [ ] 输入包含正负值、零、随机值；如测试 NaN/Inf，明确比较语义
- [ ] 检查 kernel launch 和同步时的 CUDA error

## 4. Experiment log

### EXP-001 — Block size

- 日期 / commit：`[填写]`
- 假设：增大 block size 会改变线程调度和访存吞吐；预期收益依赖 N/GPU，未必单调。
- 变量：只改变 blockDim.x；保持编译选项、N、warmup、重复次数和计时范围一致。
- 结果：导入已做过的 block size 实验并重新规范格式。
- 结论：`[填写 measured evidence，不先预设结论]`

## 5. Exit checklist

- [ ] correctness / edge cases
- [ ] 记录真实环境和 commit
- [ ] warmup + 多次 CUDA event timing
- [ ] 记录 median latency 和 effective bandwidth
- [ ] 解释小输入与大输入的差异
- [ ] 能不看笔记解释 grid/block/index 与越界保护
