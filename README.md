# cuda-study

一套可持续、AI 工具无关的 CUDA 学习仓库。目标不是“看完教程”，而是形成可以复用的能力：读懂算子数学与数据流，写出正确 kernel，测出可信性能，定位瓶颈，并解释为什么某种优化有效。

## 设计原则

1. **仓库是事实源**：学习目标、状态、实验、笔记、benchmark、复盘都以 Git 中的 Markdown/CSV/代码为准；聊天记录只是临时交互，不是唯一知识库。
2. **AI 是可替换的助教**：任何模型都通过 `AGENTS.md` 和 `prompts/` 获得项目上下文。不能把学习状态只存到某个产品的记忆里。
3. **先正确，再测量，再优化**：每次性能结论都能追溯到代码版本、GPU、软件环境、输入形状和测量方法。
4. **每个 kernel 都要讲得清**：完成标准不仅是跑通，还包括边界测试、性能解释、优化假设和复盘。
5. **低摩擦优先**：初期只需要 VS Code、Git、Markdown、CSV、`nvcc` 和小脚本；不要先搭数据库、向量库或复杂 Agent。

## 目录导航

- `START_HERE.md`：第一次使用流程
- `AGENTS.md`：给 ChatGPT、DeepSeek、IDE Agent 等模型共用的项目约定
- `docs/profile.md`：你的背景、目标与边界
- `docs/learning-objectives.md`：能力目标与毕业标准
- `docs/roadmap.md`：分阶段学习路线与验收门槛
- `docs/kernel-catalog.md`：kernel 队列、优先级和进度
- `docs/progress.md`：唯一的总进度面板
- `templates/`：学习 session、kernel lab、概念笔记、周复盘、性能分析模板
- `prompts/`：可跨 AI 工具复用的任务提示词
- `labs/`：代码、测试和实验的主目录
- `notes/`：跨 kernel 复用的概念知识
- `data/benchmarks/`：可被脚本读取的原始性能数据
- `scripts/`：轻量辅助脚本

## 快速启动

在 WSL2 Ubuntu 的仓库根目录：

```bash
# 1) 查看环境（工具缺失时会给出提示，不代表项目结构失败）
bash scripts/check_env.sh

# 2) 编译并运行第一个示例
nvcc -O3 -std=c++17 labs/01_cuda-basics/vector_add/vector_add.cu -o /tmp/vector_add
/tmp/vector_add 1048576

# 3) 开始一个学习记录
cp templates/study-session.md notes/sessions/$(date +%F)-first-session.md

# 4) 创建一个 kernel lab（例：reduction）
bash scripts/new_lab.sh 02-primitives reduction
```

如果已有 `cuda-study` 仓库，请先把本模板放进新分支，再按目录合并，避免覆盖已有代码和记录。

## 推荐的日常循环

1. 开始前：打开 `docs/progress.md`，只选一个 `Next Action`。
2. 学习中：先写出自己的理解/假设，再查资料或请 AI 解释。
3. 编码后：先 correctness，再 benchmark，再 profiling。不要把单次运行时间当作结论。
4. 结束前：填 `templates/study-session.md` 的简版记录，更新进度和下一步。
5. 每周：完成一次周复盘，最多选 1–3 个下周目标。
6. 每个 kernel 过关：用自己的话讲清算法、瓶颈、优化为何有效，并留下可复现结果。

## 初期不要做的事

- 不要为了“系统化”先写一个大型学习管理平台。
- 不要把完整聊天记录不加筛选地复制进笔记；保存结论、推理、失败原因、可复现命令即可。
- 不要只追求和开源 best 的倍数比较。先明确同硬件、同 dtype、同 shape、同语义、同测量范围，再比较。
- 不要在公司仓库、内部数据、未公开模型配置或业务 prompt 中直接使用个人 AI 工具。记录应使用抽象化、脱敏后的问题。
