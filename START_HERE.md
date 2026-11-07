# Start here：第一次使用模板

## 0. 先定义“完成”的含义

你的目标不是记住 API，而是对新算子能独立完成这条链路：

**数学/语义 → 数据布局与计算映射 → 正确 baseline → 测量 → 瓶颈假设 → 一次一个变量地优化 → 与可信 reference 对比 → 解释结果。**

不要要求每个 kernel 都达到开源最快实现。不同 GPU、shape、dtype、精度约束和工程边界会改变最优实现；“合格”意味着你能构造合理实现、证明正确性、定位瓶颈并做出有证据的取舍。

## 1. 先做 30 分钟仓库初始化

- [x] 打开 `docs/profile.md`，确认个人背景描述正确。
- [x] 打开 `docs/learning-objectives.md`，把每个目标标记为“未开始/进行中/已验证”。
- [x] 打开 `docs/progress.md`，写下这周可投入的真实学习时长。
- [x] 执行 `bash scripts/check_env.sh`，把实际 GPU / CUDA / compiler 信息记入 `notes/environment/`。
- [x] 把过去做过的 vector add benchmark 和代码提交记录导入第一个 lab，不要从零重做已掌握的步骤。
- [x] 建立 Git 初始提交。

## 2. 第一周只聚焦三个结果

1. 建立可复现的运行环境记录。
2. 整理并重新验证已有的 Vector Add：边界正确性、CUDA error check、warmup、重复测量和有效带宽。
3. 通过一次性能分析，能解释 Vector Add 为什么通常偏向 memory-bound，以及为什么很小的输入可能主要受 launch overhead 影响。

## 3. 学习进度规则

- **Done ≠ 看过**：一个概念“已验证”至少需要一段自己的解释、一个小实验或一个可回答的检查问题。
- **Kernel Done ≠ 只通过样例**：需跑边界/随机输入、正确性阈值、性能测量，并解释核心瓶颈。
- **Optimization Done ≠ 数字变快一次**：至少重复测量，说明运行环境和统计口径；优化前后语义一致。
- **阻塞超过两次学习 session**：把问题拆小，先写出最小复现，再求助 AI/文档/社区。

## 4. 每次学习的最小闭环

`docs/progress.md` 选任务 → 填一份 Session Note → 实现/实验 → 更新 kernel lab → 写一句“我今天改变了什么理解” → 设定下一次动作。
