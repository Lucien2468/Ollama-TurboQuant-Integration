# TurboQuant Performance Benchmarks

This document contains standardized performance metrics for the TurboQuant 3-bit engine, comparing it against reference floating-point and standard integer quantization formats.

## 1. Hardware Environment
| Component | Specification |
|-----------|---------------|
| **C**PU | [Specify CPU model e.g., Ryzen 5900X] |
| **G**PU | [Specify GPU model e.g., RTX 3080 10GB] |
| **R**AM | [Specify RAM amount e.g., 64GB DDR4] |
| **V**RAM | [Specify VRAM amount e.g., 10GB GDDR6X] |

---

## 2. Inference Throughput (Tokens per Second)
Measured using `.\perf-tests\bench-inference.ps1`. Higher is better.

| Model | Format (TURBO) | Format (Q4_0) | Speedup (vs Q4_0) |
|-------|----------------|---------------|-------------------|
| **Llama 3.2 (1B)** | [TPS] | [TPS] | [X.X]x |
| **Llama 3.2 (3B)** | [TPS] | [TPS] | [X.X]x |
| **Meta-Llama 3.1 (8B)** | [TPS] | [TPS] | [X.X]x |

---

## 3. Memory Efficiency (VRAM Usage)
Measured during inference at context length 4096.

| Model | Format (TURBO) | Format (Q4_0) | Compression (%) |
|-------|----------------|---------------|-----------------|
| **Llama 3.2 (3B)** | [MB] | [MB] | [XX]% |
| **Meta-Llama 3.1 (8B)** | [MB] | [MB] | [XX]% |

---

## 4. Kernel Micro-benchmarks (Compute Bound)
Measured using `.\perf-tests\benchmark-cuda.cu` (GPU) and `.\perf-tests\run-bench.ps1` (CPU).

| Architecture | Implementation | Throughput (TFLOPS) | Bandwidth (GB/s) |
|--------------|----------------|---------------------|------------------|
| **CUDA (GPU)** | `vec_dot_turbo_q8_1` | [X.XX] | [XXX] |
| **AVX2 (CPU)** | `vec_dot_turbo_q8_0` | [X.XX] | [XXX] |

---

## 5. Reproduction Steps
To reproduce these results in your local environment, follow these steps:

1. **Build the Engine**:
   ```powershell
   .\scripts\setup.ps1
   ```

2. **Run End-to-End Benchmarks**:
   ```powershell
   .\perf-tests\bench-inference.ps1 -Model llama3.2:1b
   ```

3. **Run Micro-benchmarks**:
   ```powershell
   # Compile and run inside the Docker environment
   .\perf-tests\run-bench.ps1
   ```
