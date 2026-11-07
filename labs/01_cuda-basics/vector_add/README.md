# Vector Add lab

这是学习系统中的第一个复盘 lab。根据已有对话，你已经做过基础 vector add 和 block size 测量；这里的目标不是机械重写，而是把零散实验升级为可复现、可解释的工程记录。

## To-do

- [x] 导入既有实现：已包含在初始提交 `dc00c7e`；更早的原始 commit 为 unknown。
- [x] 首批用户结果已保存至 `data/benchmarks/vector_add_summary.csv`；用户确认此前没有历史 benchmark。本地环境见 `notes/environment/envs`。
- [ ] 复核 host/device 内存分配、kernel launch 与错误检查。
- [ ] 添加 N=0/1、小尺寸、非 block-size 倍数、较大输入的测试（按实现接口调整）。
- [ ] 统一 warmup 与多次重复测量，至少记录 median；避免用 shell wall-clock 包住整段程序当作 kernel latency。
- [ ] 按 3*N*sizeof(float) 粗估读写数据量，计算 effective bandwidth，并说明该估算的假设。
- [ ] 对比小 N 与大 N 的延迟行为，讨论 launch overhead 和带宽瓶颈。
- [ ] 在 `LAB.md` 中记录一次 block size 变化的 hypothesis、结果和解释。

## Build and run

```bash
nvcc -O3 -std=c++17 vector_add.cu -o /tmp/vector_add
/tmp/vector_add 256
```

以上命令在本 lab 目录运行。第一个参数是 `block_size`，第二个可选参数是 N（默认 `1 << 24`）。预热 1 次，测 20 批，每批重复 100 次，汇总报告批次均值的中位数。按当前学习范围约定传入合法参数。grid 公式和 N=0 空操作已处理；尾部 N=257 已通过 memcheck，见 LAB.md。

从仓库根目录使用自动编译、运行和 CSV 记录：

```bash
python3 scripts/benchmark_vector_add.py --block-size 256
```

结果追加到 `data/benchmarks/vector_add_summary.csv`；完整规则见 `data/benchmarks/README.md`。

## Files

- `vector_add.cu`：简单 correctness + CUDA event timing 的可编译起始实现
- `LAB.md`：复制自 kernel lab 模板后补全
