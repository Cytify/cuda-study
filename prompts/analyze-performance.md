# Prompt: analyze kernel performance

请参考 `AGENTS.md`、当前 `LAB.md` 和原始 benchmark CSV，分析这次性能实验。

环境、shape、dtype、commit 和测量口径必须从文件或我提供的信息中读取；未知项标注 unknown，不要编造。

我希望得到：
1. 数据质量检查：warmup、重复次数、统计量、GPU 干扰、计时范围是否可比较。
2. 理论模型：估算 memory traffic、FLOPs、effective bandwidth 或 TFLOP/s（仅在有足够信息时）。
3. 瓶颈假设排序：每个假设都给出支持证据、缺失证据和能区分它的下一项实验。
4. 最多建议两个下一步实验；每个实验一次只改一个主要变量。
5. 可直接写回 `LAB.md` 的结论段落，并明确适用范围。

不要把一次微小波动当作稳定优化；不要把不同硬件、shape、dtype 或 timed region 的数字直接当成公平对比。
