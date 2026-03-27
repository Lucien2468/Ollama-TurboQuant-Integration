# TurboQuant Developer Walkthrough

This document provides a technical roadmap of the modifications made to the Ollama and GGML ecosystems to enable native 3-bit (TURBO) support.

## Repository Structure
To maintain a professional ecosystem, the project is structured as follows:

- **ollama/**: Custom fork of the Ollama source code.
- **llama.cpp/**: Custom fork of the llama.cpp backend used by Ollama.
- **scripts/**: Automation tools for building and running the Dockerized engine.
- **examples/**: Blueprint Modelfiles for standard LLMs.

---

## Core Source Modifications

### 1. GGML Backend (C++)
We have surgically extended the GGML library to recognize GGML_TYPE_TURBO:
- **ollama/ml/backend/ggml/ggml/include/ggml.h**: Registered GGML_TYPE_TURBO (ID 41).
- **ollama/ml/backend/ggml/ggml/src/ggml-quants.h**: Defined the block_turbo bit-packing structure. We use a 32-element block size to balance memory alignment and quantization entropy.
- **ollama/ml/backend/ggml/ggml/src/ggml-quants.c**: Implementation of quantize_row_turbo_ref and dequantize_row_turbo. These kernels handle the bit-level packing and unpacking of weights.

### 2. CPU Inference Layer
To enable model execution (inference), we implemented specialized math kernels:
- **ollama/ml/backend/ggml/ggml/src/ggml-cpu/quants.c**: Added ggml_vec_dot_turbo_q8_0, a dedicated 3-bit dot product kernel that allows the CPU to perform math directly on packed weights.
- **ollama/ml/backend/ggml/ggml/src/ggml-cpu/ggml-cpu.c**: Registered the TURBO type in the CPU dispatch table (type_traits_cpu).

### 3. Ollama Bridge (Go)
The Go-side of Ollama was updated to handle the new tensor type during the create and push flows:
- **ollama/fs/ggml/type.go**: Added TensorTypeTURBO to the Ollama filesystem layer.
- **ollama/ml/backend/ggml/quantization.go**: Added logic to recognize the --quantize turbo flag and map it to the C++ backend.

---

## Build Pipeline
The repository uses a automated Docker build to ensure performance-optimized binaries:
- **Dockerfile.turbo**: Uses multi-stage builds to compile both the Go frontend and the C++ backend with SIMD optimizations (AVX/AVX2).
- **scripts/setup.ps1**: The entry point for building the image.
- **scripts/turbo-ollama.ps1**: A wrapper that maps local model storage (d:\turboquant\.ollama) into the container for persistence.

---

## Future Research Directions
We are currently exploring:
1. Entropy coding for 3-bit blocks to further reduce size.
2. SIMD/AVX-512 optimizations for the dequantization loop.
3. Vulkan/Metal shader support for cross-platform GPU quantization.

---
*Authored by Lucien Hu.*
