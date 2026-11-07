# Repository workflow and source of truth

## 哪类信息放哪里？

| 信息 | 唯一主要存放点 | 不要怎么做 |
|---|---|---|
| 总学习状态 | `docs/progress.md` | 不要只存在 AI 对话里 |
| Kernel 队列与优先级 | `docs/kernel-catalog.md` | 不要用多个相互矛盾的 TODO 文件 |
| 单次学习过程 | `notes/sessions/YYYY-MM-DD-*.md` | 不必逐字保存整段聊天 |
| 单个 kernel 的规格、实现方案、迭代 | `labs/<phase>/<kernel>/LAB.md` | 不要把多个 kernel 的实验混在一起 |
| 正式概念笔记 | `notes/concepts/` | 不要把未验证猜想写成事实 |
| 原始 benchmark 记录 | `data/benchmarks/*.csv` | 不要只留截图或手工抄出的单一最佳数值 |
| 性能解释与图 | 对应 `LAB.md` 或 `reports/` | 不要把未经复测的波动写成优化结论 |
| AI 提示词 | `prompts/` + `AGENTS.md` | 不要绑定某一家产品的私有记忆 |

## 推荐每周节奏

- 每次 session：一个主目标 + 一个可见产物 + 一个 next action。
- 每周：从未完成项里挑 1–3 个可交付目标；周末记录已证实的进步、没完成原因和下周首个动作。
- 每月：抽一个已学 kernel，不看旧代码重新写简化版本，检查知识是否真正内化。

## Git 建议

- 小步提交，提交信息说明实验目的，例如 `lab(reduction): add warp-level baseline`。
- 每次重要 benchmark 记录对应的 Git commit hash。
- 不把编译产物、巨大 profiler trace、敏感公司代码或模型权重提交到仓库。
- 如果需要同步到远端，选择自己有权限且符合数据安全要求的私有/公开仓库。

## 保持 AI 可迁移

每次调用新的 AI 工具，提供以下最小上下文：

1. `AGENTS.md`
2. `docs/profile.md`
3. `docs/progress.md`
4. 当前任务对应的 `LAB.md` / concept note
5. 对应的 `prompts/*.md`

更换模型后不需要迁移聊天历史，因为实际目标、状态、实验和结论已存回仓库。
