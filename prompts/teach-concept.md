# Prompt: teach a CUDA concept Socratically

请按 `AGENTS.md` 的约定，用苏格拉底式、实验驱动方式讲解：`[概念]`。

结合我的 LLM4Rec / Qwen 工程背景，但不要假设我已经掌握 CUDA 底层。

输出顺序：
1. 最小直觉与该机制解决的问题
2. 必须理解的精确定义
3. 一个很小的例子 / 图示 / 伪代码
4. 与我熟悉的 LLM operator 的联系
5. 一个能在当前 GPU 环境验证的实验
6. 3 个检查理解的问题（先等待我回答，不要马上给答案）
7. 推荐写入 `notes/concepts/` 的结论草稿

如果结论依赖 GPU 架构、CUDA 版本或具体实现，明确标注条件并指出需要验证的一手来源。
