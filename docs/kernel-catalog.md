# Kernel catalog

状态只使用：`未开始` / `进行中` / `待复盘` / `已验证` / `暂缓`。完成度按能力证据而不是代码行数衡量。

| ID | Kernel / Topic | 阶段 | 优先级 | 当前状态 | 验收证据 / 下一步 |
|---|---|---:|---|---|---|
| K001 | Vector Add | 1 | P0 | 待复盘 | 已有 CPU reference、尺寸检查、memcheck、多批/规模/block 对照与 ncu；下次独立解释 occupancy 与 DRAM 吞吐后收尾，见 LAB.md 与 reports/PROFILING.md |
| K002 | Strided access / transpose | 2 | P0 | 未开始 | 对照访问模式并记录 coalescing 与布局影响 |
| K003 | Sum reduction | 3 | P0 | 未开始 | naive、warp/block reduction；非整除 N；误差分析 |
| K004 | Max reduction | 3 | P1 | 未开始 | mask / identity value / 非整除长度 |
| K005 | Prefix sum / scan | 3 | P1 | 未开始 | 单 block 版本起步；理解 scan 与 reduction 的差异 |
| K006 | Naive GEMM | 4 | P0 | 未开始 | M/N/K 不同、边界 tile、reference 对比 |
| K007 | Tiled GEMM | 4 | P0 | 未开始 | shared-memory tiling、数据复用、资源分析 |
| K008 | Tensor Core GEMM reading/lab | 4 | P1 | 未开始 | 按实际 GPU arch 和 dtype 决定可用实验 |
| K009 | RMSNorm | 5 | P0 | 未开始 | reference、误差、row length 与融合分析 |
| K010 | LayerNorm | 5 | P1 | 未开始 | 均值/方差算法、稳定性、两遍/一遍差异 |
| K011 | Softmax | 5 | P0 | 未开始 | max-subtract、mask、row width、稳定性 |
| K012 | RoPE | 5 | P0 | 未开始 | layout/position/sequence offset 与边界测试 |
| K013 | SwiGLU / fused MLP fragment | 5 | P1 | 未开始 | 算子融合、读写减少与 register pressure |
| K014 | Embedding / gather-scatter | 5/7 | P1 | 未开始 | irregular access 与索引有效性 |
| K015 | Naive attention | 6 | P0 | 未开始 | causal mask、softmax、reference 与显存规模 |
| K016 | FlashAttention design / reproduction | 6 | P0 | 未开始 | 固定论文/实现版本；画 tile 数据流与在线 softmax |
| K017 | MoE routing/top-k | 7 | P1 | 未开始 | routing correctness、tie/empty expert 处理 |
| K018 | MoE dispatch/permutation | 7 | P1 | 未开始 | scan/count、gather-scatter、buffer layout |
| K019 | Grouped expert GEMM | 7 | P1 | 未开始 | expert token counts / workload skew / reference |
| K020 | DeepSeek-specific attention subproblem | 8 | P2 | 未开始 | 先固定论文或代码 commit，不能只用模糊名称 |

## 新增 kernel 的规则

新 kernel 开始前，先在此表增加一行，再复制 `templates/kernel-lab.md` 到 `labs/<phase>/<kernel>/LAB.md`。每个任务只指定一个当前 `Next Action`；不要同时开超过 2 个未收尾的 lab。
