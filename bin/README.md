# deming-eval: Binary Evaluation Release

`deming-eval` is a standalone, stripped 64-bit ELF executable compiled for Linux x86_64.
It provides the bare-metal evaluation runtime for the Deming Engine inference architecture described in the preprint *"Beyond the Monolithic Wall"*.

## Binary Specifications

* **Architecture:** Linux x86_64 (ELF 64-bit LSB pie executable)
* **Optimization:** Release profile with link-time optimization (LTO)
* **Symbol Stripping:** Stripped (`strip -s`)
* **Dynamic Linking:** Standard GNU C runtime (`libc.so.6`, `libm.so.6`, `libgcc_s.so.1`, `/lib64/ld-linux-x86-64.so.2`)
* **Hardware Acceleration:** Dynamically interfaces with Vulkan 1.3 (`libvulkan.so.1`), AMD ROCm / HIP (`libamdhip64.so`), or NVIDIA CUDA via runtime driver dispatch.
* **Telemetry & Cloud Dependency:** Zero external network requests, zero telemetry beaconing, zero licensing server checks.

## Purpose & Source Note

This pre-compiled binary is provided to allow independent researchers and developers to verify the empirical performance metrics (throughput, latency, TTFT, and energy per token) published in the preprint on their own hardware without requiring the proprietary compilation toolchain.

Because this file is a compiled binary executable, GitHub does not render source code.

## Verification Command

To verify hardware detection and driver compatibility on your machine:

```bash
./bin/deming-eval --probe-hardware
```

Sample output:
```json
{"available_memory_mb":32768,"backend":"vulkan","device_name":"AMD Radeon AI PRO R9700"}
```
