# Environment snapshots

每当驱动、CUDA toolkit、编译器、GPU、环境容器或关键 flags 改变时，新增一份快照，例如 `2026-10-22-local-wsl.md`。

记录：

- OS / WSL distro / kernel
- GPU name、compute capability、VRAM
- Windows NVIDIA driver 版本、`nvidia-smi` 输出
- CUDA toolkit (`nvcc --version`)、compiler、CMake
- 编译 flags、目标 architecture（如 `-arch=sm_XX`）
- 相关库版本、环境变量
- GPU 是否被共享/占用
- 生成快照的命令

注意：WSL 环境的驱动与 toolkit 角色不要混淆；按 Microsoft/NVIDIA 当前官方指引安装和检查，不在笔记里盲目硬编码某个 CUDA 版本。
