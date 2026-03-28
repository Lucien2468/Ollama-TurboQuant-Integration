# TurboQuant Developer Walkthrough

This document provides a technical roadmap of the modifications made to the Ollama and GGML ecosystems to enable native 3-bit (TURBO) support across CPU and GPU backends.

## Repository Structure
To maintain a professional ecosystem, the project is structured as follows:

- **ollama/**: Custom fork of the Ollama source code.
- **scripts/**: Automation tools for building and running the Dockerized engine.
- **examples/**: Blueprint Modelfiles for standard LLMs.

---

## Core Source Modifications

### 1. GGML Backend (C++)
We have surgically extended the GGML library to recognize GGML_TYPE_TURBO:
- **ollama/ml/backend/ggml/ggml/include/ggml.h**: Registered GGML_TYPE_TURBO (ID 41).
- **ollama/ml/backend/ggml/ggml/src/ggml-common.h**: Defined the `block_turbo` bit-packing structure (2-byte scale + 12-byte payload).
- **ollama/ml/backend/ggml/ggml/src/ggml-quants.c**: Implementation of `quantize_row_turbo_ref` and `dequantize_row_turbo`.

### 2. CPU Inference Layer
Specialized math kernels for high-speed CPU execution:
- **ollama/ml/backend/ggml/ggml/src/ggml-cpu/quants.c**: Added `ggml_vec_dot_turbo_q8_0`, a dedicated AVX2/FMA dot product kernel.
- **ollama/ml/backend/ggml/ggml/src/ggml-cpu/ggml-cpu.c**: Registered the TURBO type in the CPU dispatch table (`type_traits_cpu`).

### 3. GPU Acceleration (CUDA)
High-throughput kernels for NVIDIA hardware:
- **ollama/ml/backend/ggml/ggml/src/ggml-cuda/dequantize.cuh**: Implemented `dequantize_turbo` for GPU-side bit-unpacking.
- **ollama/ml/backend/ggml/ggml/src/ggml-cuda/vecdotq.cuh**: Implemented `vec_dot_turbo_q8_1` for massive-parallel dot-product calculations.
- **ollama/ml/backend/ggml/ggml/src/ggml-cuda/mmq.cuh**: Added MMQ (Matrix-Matrix Quantized) support for batched inference throughput.
- **ollama/ml/backend/ggml/ggml/src/ggml-cuda/common.cuh**: Registered `GGML_TYPE_TURBO` in CUDA type traits.

### 4. Ollama Bridge (Go)
The Go-side of Ollama was updated to handle the new tensor type during the create and push flows:
- **ollama/fs/ggml/type.go**: Added `TensorTypeTURBO` to the Ollama filesystem layer.
- **ollama/ml/backend/ggml/quantization.go**: Added logic to recognize the `--quantize turbo` flag and map it to the C++ backend.

---

## Build Pipeline
The repository uses an automated Docker build to ensure performance-optimized binaries:
- **Dockerfile.turbo**: A universal multi-stage build using `nvidia/cuda:12.4` as the base. It compiles both the Go frontend and optimized C++ backends (CUDA + AVX2).
- **scripts/setup.ps1**: The entry point for building the universal image.
- **scripts/turbo-ollama.ps1**: A wrapper that handles port mapping, model persistence, and GPU passthrough (`--gpus all`).

---

## Future Research Directions
1. Entropy coding for 3-bit blocks to further reduce size.
2. SIMD/AVX-512 optimizations for the dequantization loop.
3. Vulkan/Metal shader support for cross-platform GPU quantization.

---
*Authored by Lucien Hu (Lead Developer)*
