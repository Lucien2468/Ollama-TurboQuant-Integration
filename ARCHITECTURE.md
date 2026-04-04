# TurboQuant: Architectural Rationale

This document details the technical design of the **TurboQuant** (3-bit asymmetric) engine. It is specifically designed to bridge the gap between 2-bit (high distortion) and 4-bit (standard) quantization by optimizing for the memory-to-compute ratios of modern NVIDIA and x86 hardware.

## 1. The 14-Byte Geometry

TurboQuant uses a specialized **14-byte block** for 32 elements:
- **Scale (FP16)**: 2 bytes.
- **Payload (3-bit)**: 12 bytes (32 elements * 3 bits = 96 bits).

### Why 14 Bytes? (The SRAM Tiling Logic)
Standard GGML types like `Q4_0` use 18-byte blocks. TurboQuant's 14-byte footprint is a deliberate choice for **SRAM-aligned tiling**:
1. **L1/Shared Memory Efficiency**: Modern GPU shared memory banks are 4 bytes wide. A 12-byte payload (3 words) fits perfectly into bank-aligned loads without generating "bank-conflict" residues that 18-byte or 20-byte blocks often suffer from.
2. **Throughput-to-Bandwidth Ratio**: On memory-bound workloads (typical for LLM inference), TurboQuant achieves a **1.28x** potential speedup over 4-bit simply by reducing the data transport volume.

## 2. Asymmetric Bit-Packing

Unlike `Q3_K` which uses a mixed 2-bit + 1-bit split across different blocks, TurboQuant uses a **pure 3rd-order bit-packing** with a "Staggered Asymmetric" layout:
- **Bit-Density**: Exactly 3 bits per element.
- **Centering**: Weights are centered at `-4 to 3` using a bias subtraction of `4`.
- **SIMD Hardening**: By using an asymmetric layout that packs 8 elements into 3 contiguous bytes, we enable **multi-stage bitwise reconstruction** that avoids the overhead of fragmented bit-plane management.

## 3. Hardware Acceleration Path

- **CUDA**: TurboQuant leverages the **`dp4a` (Dot Product 4-byte Accumulate)** instruction. By pre-centering weights in the tiling phase, we feed optimized 8-bit integers directly into the hardware engine, maximizing tensor throughput.
- **CPU (AVX2)**: Our custom kernels use **Bit-Parallel Vector processing**. Instead of expensive float conversions, we perform partial-sum accumulations on packed registers, minimizing the "unpacking tax" traditionally associated with 3-bit logic.

## 4. Conclusion on "Google TurboQuant" Comparisons
While sharing the name "TurboQuant" with various research papers on quantization, our implementation is specifically tailored for the **GGML/Ollama ecosystem**. Our focus is on **Hardware-Native 3-bit Acceleration**, providing a production-ready alternative to standard quantization formats that is faster than 4-bit while maintaining significantly higher perplexity than 2-bit.
