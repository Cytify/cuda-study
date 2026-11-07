# Prompt: turn an LLM operator paper into a kernel plan

请和我一起分析以下论文/模型实现：`[URL / paper title / repo commit]`。

先确认目标版本和术语，不要把不同 Qwen/DeepSeek 版本或不同 attention 机制混在一起。

按顺序产出：
1. 精确的数学语义、输入输出张量、shape、dtype、layout、mask。
2. 从输入到输出的数据流图，并标注每个 buffer 的 shape/生命周期。
3. 哪些部分是 GEMM、reduction、softmax、elementwise、gather/scatter、top-k 等已知 primitives。
4. 最小 reference 算法和 correctness oracle。
5. baseline kernel 拆分方案；先不做过早融合。
6. 可能的 fusion / tiling / memory reuse / async pipeline 方向及 trade-offs。
7. 主要 correctness、precision、load-balancing 与性能风险。
8. 一份最小可行实验清单和逐级验收标准。

每条有关论文实现的事实都要链接到一手来源或具体代码位置；不能确认的地方明确标注为待验证。
