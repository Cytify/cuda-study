#include <cuda_runtime.h>

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <iostream>
#include <vector>

#define CUDA_CHECK(call)                                                       \
  do {                                                                         \
    cudaError_t err = (call);                                                  \
    if (err != cudaSuccess) {                                                  \
      std::cout << cudaGetErrorString(err) << std::endl;                       \
      std::exit(EXIT_FAILURE);                                                 \
    }                                                                          \
  } while (0)

__global__ void vector_add(const float *a, const float *b, float *c,
                           uint32_t n) {
  uint32_t idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n) {
    c[idx] = a[idx] + b[idx];
  }

  return;
}

int main(int argc, char **argv) {
  uint32_t n = argc > 2 ? std::atoi(argv[2]) : (1 << 24);
  uint32_t block_size = argc > 1 ? std::atoi(argv[1]) : 256;

  if (n == 0) {
    std::cout << "N=0: no kernel launch required; correctness PASS\n";
    return 0;
  }

  std::vector<float> h_a(n);
  std::vector<float> h_b(n);
  std::vector<float> h_c(n);

  for (size_t i = 0; i < n; ++i) {
    h_a[i] = static_cast<float>(i % 17) - 8.0f;
    h_b[i] = static_cast<float>(i % 13) + 6.0f;
  }

  float *d_a;
  float *d_b;
  float *d_c;
  size_t bytes = sizeof(float) * n;

  CUDA_CHECK(cudaMalloc(&d_a, bytes));
  CUDA_CHECK(cudaMalloc(&d_b, bytes));
  CUDA_CHECK(cudaMalloc(&d_c, bytes));

  CUDA_CHECK(cudaMemcpy(d_a, h_a.data(), bytes, cudaMemcpyHostToDevice));
  CUDA_CHECK(cudaMemcpy(d_b, h_b.data(), bytes, cudaMemcpyHostToDevice));

  uint32_t grid_size = (n + block_size - 1) / block_size;

  vector_add<<<grid_size, block_size>>>(d_a, d_b, d_c, n);
  CUDA_CHECK(cudaGetLastError());
  CUDA_CHECK(cudaDeviceSynchronize());
  // 统计 cuda kernel 运行时间
  cudaEvent_t start, stop;
  CUDA_CHECK(cudaEventCreate(&start));
  CUDA_CHECK(cudaEventCreate(&stop));
  uint32_t iters = 100;
  float total_ms = 0.0f;
  std::vector<double> batch_avg_ms;
  for (size_t batch = 0; batch < 20; ++batch) {
    CUDA_CHECK(cudaEventRecord(start));

    for (int i = 0; i < iters; ++i) {
      vector_add<<<grid_size, block_size>>>(d_a, d_b, d_c, n);
    }
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaEventRecord(stop));
    CUDA_CHECK(cudaEventSynchronize(stop));

    CUDA_CHECK(cudaEventElapsedTime(&total_ms, start, stop));

    batch_avg_ms.push_back(static_cast<double>(total_ms) / iters);
  }

  CUDA_CHECK(cudaMemcpy(h_c.data(), d_c, bytes,
                        cudaMemcpyDeviceToHost));

  for (size_t i = 0; i < n; ++i) {
    auto expected = h_a[i] + h_b[i];
    if (h_c[i] != expected) {
      std::cout << "Index " << i << ", got=" << h_c[i]
                << ", expected=" << expected << std::endl;
      return -1;
    }
  }

  for (size_t i = 0; i < batch_avg_ms.size(); ++i) {
    std::printf("Batch: %zu, Average time = %.9f ms\n", i, batch_avg_ms[i]);
  }

  auto sorted_ms = batch_avg_ms;
  std::sort(sorted_ms.begin(), sorted_ms.end());
  const size_t middle = sorted_ms.size() / 2;
  const double median_ms = (sorted_ms[middle - 1] + sorted_ms[middle]) / 2.0;
  double bandwidth_gbs =
      (3.0 * static_cast<double>(bytes)) / (median_ms * 1e-3) / 1e9;

  std::printf("N = %d\n", n);
  std::printf("Block size = %d\n", block_size);
  std::printf("Grid size = %d\n", grid_size);
  std::printf("Warmup = 1\nRepeats = %u\nBatches = %zu\n", iters, batch_avg_ms.size());
  std::printf("Median batch-mean time = %.9f ms\n", median_ms);
  std::printf("Effective bandwidth = %.6f GB/s\n", bandwidth_gbs);
  std::printf("Correctness: PASS\n");

  CUDA_CHECK(cudaEventDestroy(start));
  CUDA_CHECK(cudaEventDestroy(stop));
  CUDA_CHECK(cudaFree(d_a));
  CUDA_CHECK(cudaFree(d_b));
  CUDA_CHECK(cudaFree(d_c));

  return 0;
}
