#include <cuda_runtime.h>

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
  uint32_t n = 1 << 24;
  uint32_t block_size = argc > 1 ? std::atoi(argv[1]) : 256;
  uint32_t iters = 100;

  std::vector<float> h_a(n, 1.0f);
  std::vector<float> h_b(n, 2.0f);
  std::vector<float> h_c(n);

  float *d_a;
  float *d_b;
  float *d_c;
  size_t bytes = sizeof(float) * n;

  CUDA_CHECK(cudaMalloc(&d_a, bytes));
  CUDA_CHECK(cudaMalloc(&d_b, bytes));
  CUDA_CHECK(cudaMalloc(&d_c, bytes));

  CUDA_CHECK(cudaMemcpy(d_a, h_a.data(), bytes, cudaMemcpyHostToDevice));
  CUDA_CHECK(cudaMemcpy(d_b, h_b.data(), bytes, cudaMemcpyHostToDevice));

  uint32_t grid_size = (n + block_size + 1) / block_size;

  vector_add<<<grid_size, block_size>>>(d_a, d_b, d_c, n);
  CUDA_CHECK(cudaGetLastError());
  CUDA_CHECK(cudaDeviceSynchronize());

  CUDA_CHECK(cudaMemcpy(const_cast<float *>(h_c.data()), d_c, bytes,
                        cudaMemcpyDeviceToHost));

  // 统计 cuda kernel 运行时间
  cudaEvent_t start, stop;
  CUDA_CHECK(cudaEventCreate(&start));
  CUDA_CHECK(cudaEventCreate(&stop));

  CUDA_CHECK(cudaEventRecord(start));
  for (int i = 0; i < iters; ++i) {
    vector_add<<<grid_size, block_size>>>(d_a, d_b, d_c, n);
  }
  CUDA_CHECK(cudaGetLastError());
  CUDA_CHECK(cudaEventRecord(stop));
  CUDA_CHECK(cudaEventSynchronize(stop));

  float total_ms = 0.0f;
  CUDA_CHECK(cudaEventElapsedTime(&total_ms, start, stop));

  for (size_t i = 0; i < n; ++i) {
    if (h_c[i] != 3.0f) {
      std::cout << "Index " << i << " result mismatch." << std::endl;
      return -1;
    }
  }

  double avg_ms = total_ms / iters;
  double bandwidth_gbs =
      (3.0 * static_cast<double>(bytes)) / (avg_ms * 1e-3) / 1e9;

  std::printf("N = %d\n", n);
  std::printf("Block size = %d\n", block_size);
  std::printf("Grid size = %d\n", grid_size);
  std::printf("Average time = %.4f ms\n", avg_ms);
  std::printf("Effective bandwidth = %.2f GB/s\n", bandwidth_gbs);
  std::printf("Correctness: PASS\n");

  CUDA_CHECK(cudaEventDestroy(start));
  CUDA_CHECK(cudaEventDestroy(stop));
  CUDA_CHECK(cudaFree(d_a));
  CUDA_CHECK(cudaFree(d_b));
  CUDA_CHECK(cudaFree(d_c));

  return 0;
}