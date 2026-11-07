#!/usr/bin/env bash
set +e

echo '=== OS ==='
uname -a
if [ -r /etc/os-release ]; then cat /etc/os-release; fi

echo
echo '=== GPU / driver (nvidia-smi) ==='
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi
else
  echo 'nvidia-smi not found: GPU passthrough/driver path may not be available in this shell.'
fi

echo
echo '=== CUDA compiler ==='
if command -v nvcc >/dev/null 2>&1; then nvcc --version; else echo 'nvcc not found'; fi

echo
echo '=== Build tools ==='
for tool in g++ clang++ cmake make git python3; do
  if command -v "$tool" >/dev/null 2>&1; then printf '%-10s %s\n' "$tool" "$(command -v "$tool")"; else printf '%-10s %s\n' "$tool" 'not found'; fi
done

echo
echo 'Environment check finished. Save relevant output to notes/environment/; redact anything sensitive.'
