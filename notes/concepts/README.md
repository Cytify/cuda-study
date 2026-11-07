# Concept notes

只有值得跨 kernel 复用的概念才独立成文，例如 warp execution、coalescing、reduction tree、online softmax、register pressure。单个 kernel 的实验细节留在对应 `LAB.md`。

新建笔记：

```bash
cp templates/concept-note.md notes/concepts/concept-name.md
```

建议主题首批：
- `thread-block-warp.md`
- `memory-coalescing.md`
- `reduction-and-shuffle.md`
- `roofline-and-effective-bandwidth.md`
- `floating-point-tolerance.md`
- `occupancy-and-register-pressure.md`
- `online-softmax.md`
