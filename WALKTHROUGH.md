# TurboQuant Technical Architecture & Implementation

This document provides a rigorous technical roadmap of the modifications made to the Ollama and GGML ecosystems to enable native 3-bit (TURBO) support across diverse hardware backends.

## 1. Mathematical Foundation
TurboQuant implements an **asymmetric 3-bit quantization scheme** with a block size of 32 elements. Each block consists of:
- **16-bit Scale (fp16)**: Controls the dynamic range of the block.
- **12-byte Payload**: Stores 32 elements of 3-bit data, packed into a continuous bit-stream.

The choice of 32 elements ensures optimal alignment with modern SIMD register widths (256-bit AVX2) and memory bus transactions.

---

## 2. Core Source Modifications

### 2.1. GGML Backend (C++)
The GGML library was surgically extended to support `GGML_TYPE_TURBO`:
- **`ggml.h`**: Registered `GGML_TYPE_TURBO` (ID 41).
- **`ggml-common.h`**: Defined the `block_turbo` structure.
- **`ggml-quants.c`**: Implementation of `quantize_row_turbo_ref` and `dequantize_row_turbo`, providing the reference bit-level logic.

### 2.2. CPU Inference Layer (AVX2/FMA)
High-performance math kernels for Intel/AMD architectures:
- **`ggml-cpu/quants.c`**: Added `ggml_vec_dot_turbo_q8_0`, a specialized dot product kernel.
- **Logic**: Unpacks 3rdnd-bit weights into intermediate 8-bit registers and performs fused multiply-add operations against the Q8_0 activation vector.
- **`ggml-cpu/ggml-cpu.c`**: Registered the TURBO type in the CPU dispatch table (`type_traits_cpu`).

### 2.3. GPU Acceleration (CUDA)
High-throughput kernels for NVIDIA GPGPU acceleration:
- **`dequantize.cuh`**: Implemented `dequantize_turbo` for massively parallel bit-unpacking on the GPU.
- **`vecdotq.cuh`**: Developed `vec_dot_turbo_q8_1` and its `dp4a` variant, optimized for Ampere and later architectures.
- **`mmq.cuh`**: Integrated Matrix-Matrix Quantized (MMQ) support for batched inference scalability.
- **`common.cuh`**: Registered `GGML_TYPE_TURBO` in CUDA hardware type traits.

### 2.4. Ollama Bridge (Go)
The Ollama frontend was updated to navigate the new tensor type:
- **`fs/ggml/type.go`**: Registered `TensorTypeTURBO` in the Ollama filesystem layer.
- **`ml/backend/ggml/quantization.go`**: Extended the `--quantize` CLI handler to map the `turbo` flag to the GGML backend.

---

## 3. Build & Runtime Orchestration
TurboQuant utilizes a unified, multi-stage Docker build to ensure performance-optimized binary distribution:
- **Universal Dockerfile**: A single `Dockerfile.turbo` builds both the Go frontend and optimized C++ backends (CUDA + AVX2).
- **Hardware Dispatch**: The Ollama runner automatically detects host-side CUDA availability and selects the optimal acceleration path at runtime.

---
*Technical Documentation maintained by Lucien Hu (Lead Developer)*
