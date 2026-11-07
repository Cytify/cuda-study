# Learning objectives & graduation rubric

状态定义：`未开始` / `进行中` / `已验证`。只有能在没有 AI 代写的情况下讲清楚、并能用代码/实验佐证，才可标记“已验证”。

## O1. CUDA execution model

- 能解释 grid/block/warp/thread、SIMT、线程索引和 kernel launch。
- 能解释 host/device 内存、同步边界、异步执行和常见错误检查方式。
- 能使用边界测试发现 indexing bug。
- 证据：实现并说明 Vector Add；通过非整除 size 与小规模 edge cases。

`进行中`

## O2. Memory hierarchy & performance reasoning

- 能解释 coalescing、global/shared/register、bank conflict、cache 的影响。
- 能估算 bytes moved、effective bandwidth、FLOP、arithmetic intensity，并识别可能的瓶颈。
- 能区分 kernel launch overhead 与 steady-state kernel latency。
- 证据：Vector Add + transpose/strided access 的对照实验和性能分析。

` 未开始`

## O3. Reduction and parallel primitives

- 能实现 sum/max reduction，理解 warp shuffle、shared-memory reduction、分层 reduction 与 atomic 的取舍。
- 理解浮点 reduction 顺序变化对数值结果的影响。
- 认识 scan/prefix sum、gather/scatter、histogram 等不属于“简单 elementwise”的模式。
- 证据：reduction 多版本实现、非 2 的幂长度测试、误差分析。

` 未开始`

## O4. GEMM & matrix compute

- 能实现 naive GEMM 和 tiled GEMM，解释数据复用和 tiling。
- 理解资源使用、occupancy、register pressure、shared-memory bank conflicts 的影响。
- 能描述 FP32/TF32/FP16/BF16 与 Tensor Core 路径的精度和性能权衡（具体支持以 GPU 架构为准）。
- 证据：与 cuBLAS 等可信 reference 在明确的 shape/dtype/测量条件下比较。

` 未开始`

## O5. Transformer / Qwen operator literacy

- 能从 module 的数学定义识别 GEMM、reduction、elementwise、normalization、RoPE、softmax、attention、gather/scatter 等子问题。
- 能说明哪些融合能减少 memory traffic/launches，哪些融合会增加寄存器压力或限制并行度。
- 证据：RMSNorm、RoPE、Softmax、SwiGLU 至少完成其中三项的 baseline、测试与分析。

` 未开始`

## O6. Attention, MoE and sparse patterns

- 能从定义出发实现 naive attention，解释 causal mask、scale、softmax 稳定性和中间矩阵的内存代价。
- 能解释 FlashAttention / online softmax / tiling 的核心思想与限制。
- 能拆解 MoE 的 routing、token dispatch/permutation、expert GEMM、combine；理解不规则访存和负载不均。
- 对 DeepSeek 系列的稀疏注意力/压缩 KV 等机制，以具体论文和模型版本为准，不把不同版本的机制混为同一个 kernel。
- 证据：至少一个 attention 核心版本和一个 MoE/sparse 子问题的设计文档及可验证实现。

` 未开始`

## O7. Independent kernel problem solving

面对陌生 module，能够独立产出：

1. 数学/语义与 reference
2. shape、dtype、layout、mask 和边界清单
3. 算法拆分与可能的 kernel fusion plan
4. baseline 与 correctness tests
5. 性能模型和瓶颈假设
6. profiling plan 与候选优化序列
7. 与库/论文/开源实现的公平对比方案

` 未开始`

## Graduation rubric

- **Level 1 — Can implement**：能独立实现基础版本并处理边界情况。
- **Level 2 — Can explain**：能解释线程映射、内存流量、同步和数值误差。
- **Level 3 — Can optimize**：能通过测量确定瓶颈，每次优化都有假设与证据。
- **Level 4 — Can transfer**：面对新算子，能从语义拆解到 kernel 方案，而不是照抄已有代码。

目标是达到 Level 4 的稳定方法论；不承诺在所有 GPU/shape 上超过成熟开源库。
