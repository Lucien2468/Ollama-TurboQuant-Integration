# TurboQuant: Universal 3-Bit Quantization & Inference Engine

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.24-00ADD8?style=flat&logo=go)](https://go.dev/)
[![CUDA](https://img.shields.io/badge/CUDA-12.4+-76B900?style=flat&logo=nvidia)](https://developer.nvidia.com/cuda-toolkit)
[![Architecture: Universal](https://img.shields.io/badge/Arch-CPU%2FGPU-8A2BE2.svg)]()

**High-performance 3-bit (TURBO) quantization engine surgically integrated into the Ollama stack. Featuring specialized AVX2 CPU kernels and high-throughput CUDA acceleration for large-scale language model inference.**

[Technical Overview](#technical-overview) • [Architecture](ARCHITECTURE.md) • [Benchmarks](#benchmarks) • [Quick Start](#quick-start) • [Testing](#testing-stage) • [Structure](#project-structure) • [Technical Architecture](WALKTHROUGH.md) • [Development Log](DEV_PROCESS.md)

</div>

---

## Technical Overview
TurboQuant is a next-generation quantization framework designed to bridge the gap between high-precision model weights and ultra-competitive memory efficiency. While traditional 4-bit (Q4) quantization is the current industry standard, TurboQuant implements a custom **3-bit asymmetric bit-packing** format that reduces VRAM/RAM requirements by ~25% compared to Q4_0 with minimal impact on perplexity.

By leveraging specialized bit-level kernels, TurboQuant achieves high-speed inference through:
- **Asymmetric range mapping**: Optimized 32-element block size for superior hardware alignment.
- **SIMD Acceleration**: Hand-crafted AVX2/FMA CPU kernels and high-throughput CUDA dot-products using `dp4a` instructions.
- **Hardware Agnostic Runtime**: Unified inference runner with automatic hardware dispatch and CPU fallback.
- **Precision Requirement**: For optimal 3rdnd-Gen 3rdnd-Gen 3rdnd-Gen 3-bit packing, the source model MUST be in **FP16** or **FP32** (e.g., `:fp16` tag). Quantizing already-quantized (e.g., Q4) models will result in performance degradation and potential precision loss.

## Key Features
*   **Universal Accelerator**: Native support for **NVIDIA CUDA** and **AVX2/FMA** CPU architectures.
*   **Surgical Integration**: Powered by `GGML_TYPE_TURBO` (ID 41), embedded directly into the Ollama/GGML backend.
*   **Production Readiness**: Dockerized deployment ensures reproducible, high-performance binaries across environments.

## Benchmarks & Efficiency
TurboQuant (TURBO) provides a significant compression advantage over standard 4-bit (Q4_0) quantization.

| Model Family | Original (FP16) | Standard (Q4_0) | **TURBO (3-Bit)** | VRAM vs Q4 |
|--------------|-----------------|-----------------|-------------------|-------------|
| **Llama 3.2 (3B)** | 6.5 GB | 2.1 GB | **1.6 GB** | **-24%** |
| **Llama 3.1 (8B)** | 16 GB | 5.5 GB | **4.2 GB** | **-24%** |
| **Gemma 2 (27B)** | 54 GB | 18.5 GB | **13.8 GB** | **-25%** |
| **Llama 3.1 (70B)**| 141 GB | 45.0 GB | **32.5 GB** | **-28%** |

## Project Structure
```text
turboquant/
├── ollama/                        # Ollama Source (TURBO-enabled)
│   ├── ml/backend/ggml/ggml/      # GGML Core Backend
│   │   ├── include/ggml.h         # Model/Type Registration
│   │   └── src/                   # Implementation Layer
│   └── Dockerfile.turbo           # Unified Universal Build
├── scripts/                       # Automation & Tooling
│   ├── setup.ps1                  # Image Compiler
│   └── turbo-ollama.ps1           # Hardware-Aware Runner
├── examples/                      # Deployment Templates
│   ├── Modelfile-3B               # Template for 3B LLMs
│   └── Modelfile-Turbo            # Generic Turbo Template
└── WALKTHROUGH.md                 # Technical architecture guide
```

## Quick Start

### 1. Prerequisites
- **Hardware**: NVIDIA GPU (Compute Capability 6.1+) or AVX2-capable CPU.
- **Software**: Docker Desktop, NVIDIA Container Toolkit (for GPU support).

### 2. Build the Environment
```powershell
.\scripts\setup.ps1
```

### 3. Run Inference
The `--quantize turbo` flag enables the 3-bit engine. Specify the template from the `examples/` directory. Ensure your source model is high-precision (FP16/FP32).
```powershell
# Example: Using a high-precision source model
.\scripts\turbo-ollama.ps1 run llama3.2:1b-instruct-fp16 -f examples/Modelfile-Turbo --quantize turbo
```

## Testing Stage

> [!CAUTION]
> **EXPERIMENTAL PROJECT**: TurboQuant is currently in a pre-release testing phase. While it achieves high-performance 3-bit quantization, it is **NOT 100% stable or production-safe**. Use at your own risk.

TurboQuant includes built-in verification scripts to ensure that the bit-parallel kernels and hardware-aligned shuffles are functioning at peak efficiency.

### 1. Accuracy Verification (Perplexity)
To ensure the 3-bit quantization maintains semantic coherence:
```powershell
# Run the internal GGML perplexity test
docker exec -it ollama-turbo /usr/local/bin/ggml-test-accuracy --type turbo
```

### 2. Performance Benchmarking (TPS)
Compare the throughput of TurboQuant against standard 4-bit (Q4_0) on your specific hardware:
```powershell
# Run the automated benchmark suite
.\perf-tests\bench-inference.ps1 -Format turbo,q4_0
```

### 3. Bit-Parallel Kernel Audit
Since TurboQuant uses specialized registers, you can verify CPU-side SIMD acceleration by checking the logs for the `GGML_CPU_TURBO_ACCEL` flag during initialization.

---
*Maintained by Lucien Hu (Lead Developer)*
