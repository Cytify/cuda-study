# Learner profile

> 本文件是个性化学习路线的上下文；按需更新。不要填写公司机密、内部数据、私有模型参数或敏感业务信息。

## Current background

- **领域**：LLM4Rec 工程
- **模型/训练推理场景**：Qwen 系列模型；CPT、SFT、RL；离线推理中的 sampling / beam search
- **已有经验**：训练/推理框架适配、开发、调优；对 GPU/kernel 底层有零散认知，但缺少体系和深入实践
- **开发环境**：Windows + WSL2 Ubuntu + VS Code；实际 GPU / 驱动 / CUDA 版本以 `notes/environment/` 记录为准

## Why learn CUDA

希望从典型 case 中理解 CUDA 编程，再能够手写和优化 LLM 常见算子，最终面对陌生 module / 新算法时，能自主形成 kernel implementation plan、识别瓶颈并用实验验证。

## Learning constraints

- 先重用现有环境和已完成的实验，避免为了“课程完整”重复劳动。
- 优先掌握原理、实现与测量；再追逐单一 benchmark 的极限数字。
- 学习资料和状态应能脱离任何单一 AI 产品而独立存在。
- 预计每周投入：`10` 小时。
- 偏好的 session 时长：`20~30` 分钟。

## Known starting point

- [ ] 复核 CUDA 执行模型与 launch 语义
- [ ] 复核 Vector Add 的 correctness / benchmark 口径
- [ ] 系统掌握 reduction 与 warp-level primitives
- [ ] 系统掌握 GEMM tiling 与 Tensor Core 使用条件
- [ ] 把基础知识映射到 Qwen/Transformer 的算子路径

## Personal definition of success

1. 能不依赖 AI 独立写出清晰的 kernel 方案，包含 indexing、数据布局、边界与同步策略。
2. 能写 reference/测试并解释数值容差。
3. 能基于测量和 profiler 诊断瓶颈，而非盲目改 block size。
4. 能把一个 kernel 从 baseline 推进到有证据支撑的优化版本，并公平对比公开实现。
5. 能把新论文中的算子拆成可实现的 primitives，并列出可行方案与风险。
