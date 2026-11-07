# Vector Add profiling

目标：对比 block=256 与 1024 的寄存器、资源限制、理论/实际 occupancy 及内存/计算吞吐，检验假设，不预设 2% 收益的原因。

在仓库根目录逐条运行：

```bash
bash scripts/profile_vector_add.sh 256
bash scripts/profile_vector_add.sh 1024
```

需要本地 GPU、nvcc、Nsight Compute (`ncu`)。脚本使用与 benchmark 相同的 `-O3 -std=c++17`，额外 `-Xptxas=-v` 仅用于打印编译资源信息。
跳过首次 warmup，仅采集下一次 kernel；应用后续仍会完成原有循环。
采集 LaunchStats、Occupancy、SpeedOfLight 三个 section，实际采集可能需要 replay。

每次输出保存在独立的 `reports/profiling/vector-add-block*-*/`：

- `environment.txt`：时间、参数、编译器、工具版本、源码 hash 和 Git 状态。
- `build.txt`：ptxas 寄存器和 spill 等编译信息。
- `ncu.txt`：可直接阅读的指标与诊断信息。
- `profile.ncu-rep`：可在 Nsight Compute GUI 打开的报告。
- `program.txt`：应用输出；其中耗时受 profiling 影响，不导入性能 CSV。

初次重点看 Registers Per Thread、Static/Dynamic Shared Memory Per Block、Block Limit 各项、Theoretical/Achieved Occupancy、Compute/DRAM Throughput。
`Memory Throughput` 汇总指标不能自动当作 DRAM 带宽利用率，需看其具体子项。
理论 occupancy 是资源推导上限；achieved occupancy 是采样/计数得到的实际活跃 warp 指标，不等于就绪 warp 或正在发射指令的比例。

如果出现 ERR_NVGPUCTRPERM，保留错误文本，按实际 Windows/WSL 环境处理计数器权限，先不重复跑采集。

官方说明：https://docs.nvidia.com/nsight-compute/NsightComputeCli/index.html

## 操作与阅读

基本形式：`ncu [采集选项] 可执行文件 [程序自己的参数]`。

```bash
nvcc -O3 -std=c++17 labs/01_cuda-basics/vector_add/vector_add.cu -o /tmp/vector_add
ncu --section LaunchStats --section Occupancy --section SpeedOfLight \
  --launch-skip 1 --launch-count 1 --page details \
  --export /tmp/vector-add-256 /tmp/vector_add 256 16777216
```

`--section` 选择指标组，`--launch-skip 1` 跳过 warmup，`--launch-count 1` 采集一次逻辑调用，`--page details` 显示指标，`--export` 保存报告。
一次逻辑调用可能为收集指标 replay 多次；7 passes 不是程序主动运行 7 次或 7 次独立性能样本。

无需重跑 kernel，可离线读取或导出报告：

```bash
ncu --import reports/profiling/vector-add-block256-qwXhDL/profile.ncu-rep --page details
ncu --import reports/profiling/vector-add-block1024-CqDK8v/profile.ncu-rep --page details
```

其他常用选项：`--list-sections`、`--list-sets`、`--set basic`、`--set full`（代价较高）、`--kernel-name regex:vector_add`、`--query-metrics`、`--metrics`、`--csv --page raw`。GUI 用 `ncu-ui 报告.ncu-rep` 打开。

阅读顺序：确认 launch/设备/参数 → 看 DRAM 与计算吞吐 → 看资源与 block limit 的最小值 → 比较理论/实际 occupancy → 按疑点补采 MemoryWorkloadAnalysis 或 SchedulerStats。自动 OPT 的估计加速比例是线索，不是可保证的收益。

## 本次采集结果

| 指标 | block=256 | block=1024 |
|---|---:|---:|
| Device CC / SM 数 | 8.6 / 46 | 8.6 / 46 |
| Registers Per Thread | 16 | 16 |
| 用户 static/dynamic shared memory | 0 / 0 | 0 / 0 |
| block limit: SM / Registers / Shared Mem / Warps | 16 / 16 / 8 / 6 | 16 / 4 / 8 / 1 |
| Theoretical Active Warps per SM | 48 | 32 |
| Theoretical Occupancy | 100% | 66.67% |
| Achieved Occupancy | 82.66% | 51.03% |
| Achieved Active Warps per SM | 39.68 | 24.49 |
| DRAM Throughput | 93.91% | 94.67% |
| Compute (SM) Throughput | 10.56% | 10.64% |
| Profiled Duration | 491.78 us | 487.49 us |

计数器支持当前大输入接近 DRAM 吞吐上限；1024 更低的 occupancy 仍保持高 DRAM 吞吐。还不能唯一定位约 2% 收益的原因；正常 benchmark 两轮仍是性能比较依据。

build.txt 显示 sm_75 编译产物使用 12 registers，而 CC 8.6 上 ncu 报告 16，实际资源分析使用后者；可能涉及运行时 PTX JIT，不能混用。若以后显式指定目标架构，需要重建对应 benchmark 基线。
