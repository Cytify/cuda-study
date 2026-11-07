# Roadmap：从 CUDA 基础到 LLM kernels

> 这是一张能力地图，不是硬性日历。每阶段按验收标准前进；不要因为日历到了就跳过不理解的内容。

## Phase 0 — 可复现实验环境

**知识点**：NVCC build、设备信息、CUDA error check、host/device 数据流、Git commit、benchmark 可复现性。

**任务**：记录环境；确认小 kernel 能编译运行；把既有 Vector Add 实验纳入仓库。

**Gate**：别人按记录能复现你的 correctness 和粗略性能测量。

## Phase 1 — CUDA 执行模型：Vector Add

**知识点**：thread/block/grid、warp、indexing、bounds check、launch overhead、kernel launch / synchronization。

**实验**：不同 N、不同 block size、整除/非整除输入；区分 correctness 与 performance。

**Gate**：能解释 grid size、尾部元素、测量噪声和有效带宽。

## Phase 2 — 内存访问与基本并行模式

**Kernel**：copy / vector add、strided access、matrix transpose。

**知识点**：coalescing、memory transaction、global/cache/shared/register、bank conflict 的基本概念、Roofline 粗估。

**Gate**：通过访问模式对照，证明内存布局能改变性能，并用证据解释原因。

## Phase 3 — Reduction / Scan / Warp primitives

**Kernel**：sum、max、row reduction、prefix sum（scan，可先做简化版）。

**知识点**：跨线程归约、warp shuffle、shared memory、同步、atomic、数值误差、非规则长度。

**Gate**：至少两种 reduction 实现；正确性覆盖非整除/空或极小输入（按接口定义）；能够解释性能与误差差异。

## Phase 4 — GEMM 与矩阵计算

**Kernel**：naive GEMM → shared-memory tiled GEMM → 进阶 tile / warp mapping；有条件时探索 Tensor Core。

**知识点**：数据复用、tiling、register blocking、shared-memory layout、occupancy/resource trade-off、数值精度、cuBLAS 对比。

**Gate**：能从矩阵乘法语义推导线程映射，并判断 baseline 慢在哪里；所有对比明确 M/N/K、dtype、transposition、alpha/beta 和测量口径。

## Phase 5 — LLM 常见 pointwise / normalization / positional operators

推荐顺序：

1. unary/binary elementwise、residual add、cast
2. RMSNorm
3. LayerNorm（重点看 reduction 与数值稳定性）
4. Softmax（max-subtract、exp、sum、mask）
5. RoPE（索引、布局、position 与 batch/sequence 维）
6. SwiGLU / GELU（elementwise + fusion）
7. embedding lookup / gather（不规则访存）

**Gate**：至少三个算子有 reference、随机与边界测试、性能分析；能解释融合减少了哪些读写/launch、引入了哪些资源代价。

## Phase 6 — Attention

顺序：attention 数学公式 → naive attention → causal/padding masks → numerically stable softmax → tiled/online-softmax 思路 → FlashAttention 实现阅读与小规模复现。

**关注点**：Q/K/V layout、head dimension、causal mask、变长 sequence、scale、FP16/BF16/FP32 累加、输出误差、分块策略和中间结果是否落到 HBM。

**Gate**：能说明 naive attention 的内存复杂度与瓶颈；能把 fused/tiled 算法的计算流程画出来；实现测试覆盖 mask 边界与不同 shape。

## Phase 7 — MoE 与不规则工作负载

顺序：top-k routing → token histogram/count → token dispatch / permutation → grouped expert GEMM → combine / unpermute → load balancing。

**知识点**：prefix sum / scan、gather-scatter、atomic、动态工作量、expert token count 分布、kernel launch 代价。

**Gate**：先把 pipeline 和每个 buffer 的 shape/layout 画清楚，再优化单个关键 kernel；记录 token 分布对 latency 的影响。

## Phase 8 — DeepSeek 系列与高级稀疏/压缩 attention

先选定一个**具体模型版本/论文/代码 commit**，再列出其注意力机制的精确定义。不要把 MLA、稀疏 attention、索引器（indexer）或不同版本的机制泛化成一个“DeepSeek sparse attention”。

推荐步骤：

1. 读论文/模型实现，写术语表、张量形状和数据流。
2. 找到与已学 primitives 对应的子问题：projection GEMM、RoPE、KV 压缩/读取、score、top-k / selection、gather、softmax、attention aggregation。
3. 画 baseline 数据流和显存读写；明确哪些阶段可融合，哪些需要跨 block 协作或独立 kernel。
4. 先实现一个有边界的子问题，再考虑端到端整合。

**Gate**：提交一份“paper-to-kernel design note”，包含引用版本、张量语义、伪代码、测试计划、瓶颈假设和风险。

## Phase 9 — 工程化和迁移能力

**内容**：C++/PyTorch extension 接口、stream 与同步、dispatch、临时 buffer 生命周期、测试矩阵、性能回归、Nsight Systems/Compute 和适合环境的 sanitizer 工具。

**Gate**：给一个陌生 module 输出设计文档、baseline、正确性测试、benchmark 和优化计划，并解释什么时候应该直接调用成熟库。

## 关键提醒

Vector Add、Reduction 和 GEMM 是极佳的基础三件套，但不足以覆盖“99%”的 CUDA 编程知识。它们不会完整覆盖 scan、稀疏/不规则访存、同步模式、动态负载、异步拷贝/流水线、Tensor Core 数据布局、数值稳定性与多 kernel pipeline。后续路线已经把这些模式逐步补进来。
