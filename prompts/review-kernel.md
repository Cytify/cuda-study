# Prompt: review a CUDA kernel

请阅读 `AGENTS.md` 和相关 `LAB.md`，评审以下实现。先不要重写整个 kernel。

代码 / diff：`[贴代码或文件路径]`

按以下优先级输出：
1. **Correctness blockers**：越界、race、同步、未初始化数据、索引溢出、错误的 mask/shape 语义。
2. **Numerics**：精度、accumulation dtype、reduction 顺序、atol/rtol、特殊值。
3. **Test gaps**：当前测试缺了哪些能暴露 bug 的 case。
4. **Performance model**：估算 bytes/FLOPs、猜测瓶颈并标注置信度。
5. **最小修改建议**：一次只建议一个主要变化，并说明预期效果与反证条件。
6. **学习提问**：问我 2–3 个问题确认我理解原因。

区分“确定的问题”和“需要 profiling 才能确认的可能瓶颈”。不要仅凭代码外观断言性能提升。
