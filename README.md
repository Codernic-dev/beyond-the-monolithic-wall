# Beyond the Monolithic Wall: Deming Engine Benchmark Suite

[![Preprint Companion](https://img.shields.io/badge/Preprint-Companion_Artifact-blue.svg)](https://github.com/Codernic-dev/beyond-the-monolithic-wall)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform: Linux x86_64](https://img.shields.io/badge/Platform-Linux_x86__64-orange.svg)]()
[![Hardware: Vulkan 1.3 / HIP](https://img.shields.io/badge/Compute-Vulkan_1.3_%7C_HIP-red.svg)]()

> **Evaluation Harness & Reproducibility Suite for the Research Preprint:**  
> *"Beyond the Monolithic Wall: Sub-Joule Reasoning and Architectural Efficiency in Edge-Native Heterogeneous Transformers"*

---

## 📌 1. Overview & Research Context

As Large Language Models scale in parameter count, edge deployment faces severe hardware bottlenecks: memory bandwidth saturation, quadratic $O(N^2)$ KV-cache explosion, and excessive thermal power dissipation.

The **Deming Engine** is a high-efficiency, bare-metal inference runtime engineered in Rust. It eliminates monolithic execution overhead through:
1. **Paged INT8 KV-Cache & Zero-Copy Sub-Buffers:** Reducing context memory consumption by up to **98.6%**.
2. **Sub-Millisecond Time-To-First-Token (TTFT):** Achieving prefill restoration in **0.19 ms** on edge hardware.
3. **Sub-Joule Energy Footprint:** Achieving **0.84 Joules per token** at high throughput via optimized Vulkan Compute Shaders and asynchronous compute queues.

This repository provides an **independent, reproducible evaluation harness**. It allows developers and researchers to verify the empirical throughput, latency, and energy metrics reported in the paper on their own hardware.

---

## 🔬 2. Author's Disclosure & Hardware Replication Notice

### Transparent Disclosure
> *I am an independent software developer with 26 years of hands-on experience in low-level systems engineering. I am neither an academic researcher nor an institutional theorist. The findings in "Beyond the Monolithic Wall" are grounded in physical measurements obtained directly from bare-metal hardware.*

### Understanding Hardware Differences & Relative Speedup
Because GPU architectures, memory bus widths, and compute unit configurations vary substantially across systems, **absolute Tokens Per Second (TPS) will naturally vary across different machines**:
* A system with an NVIDIA RTX 4090 will report different absolute throughput than an AMD Radeon AI PRO R9700 or an Apple Silicon M-series chip.
* **The definitive metric is RELATIVE EFFICIENCY:**
  $$\text{Relative Speedup} = \frac{\text{TPS}_{\text{Deming}}}{\text{TPS}_{\text{llama.cpp}}}$$
  $$\text{Energy Reduction} = 1 - \frac{\text{Joules/token}_{\text{Deming}}}{\text{Joules/token}_{\text{Baseline}}}$$
* To facilitate fair comparisons, this harness includes the `--compare-llama` flag, which executes `llama-bench` on the identical model and prompt on your machine to display your local speedup ratio.

---

## 📊 3. Reference Baseline (Paper Ground Truth)

All metrics reported in Section 5 of the preprint were captured on the following dedicated testbed:

| Component | Specification |
|---|---|
| **GPU** | AMD Radeon AI PRO R9700 (16 GB VRAM, RDNA 4 GFX1201) |
| **CPU** | Intel Core i9-12900K (16 cores / 24 threads, Alder Lake) |
| **Host Memory** | 32 GB DDR5 RAM |
| **OS & Drivers** | Linux 6.x (x86_64), Vulkan 1.3 / RADV Mesa 24.x |
| **Telemetry** | 100 Hz Sampling via AMD Sysfs Hwmon (`power1_average`) & Intel RAPL MSR |

### Summary of Reference Results

| Model | Quantization | Context | TTFT | Throughput (TPS) | Energy / Token | KV-Cache Reduction |
|---|---|---|---|---|---|---|
| **Qwen 2.5 Coder 1.5B** | Q4_K_M | 4096 | **0.19 ms** | **261.02 tok/s** | **0.84 J/tok** | **-98.6%** |
| **Qwen 2.5 Coder 7B** | Q4_K_M | 4096 | **0.28 ms** | **129.39 tok/s** | **1.42 J/tok** | **-98.6%** |

*Raw reference telemetry logs and JSON summaries are provided in [`traces/`](traces/).*

---

## 🗂️ 4. Repository Structure

```text
beyond-the-monolithic-wall/
├── bin/
│   └── deming-eval                # Stripped standalone release binary (Linux x86_64)
├── scripts/
│   ├── run_benchmark.sh           # 1-click benchmark execution script
│   ├── stress_contexts.sh         # Multi-context stress test (512 / 2048 / 8192)
│   └── telemetry_rapl_smi.py      # 100 Hz GPU + CPU energy & power telemetry sampler
├── traces/
│   ├── reference_run_1.5b.json    # Reference metrics for 1.5B model from paper
│   ├── reference_run_7b.json      # Reference metrics for 7B model from paper
│   └── reference_telemetry_r9700.csv # Real 100 Hz power dissipation profile (37-52W)
├── LICENSE                        # MIT Open-Source License
└── README.md                      # Documentation & instructions
```

---

## 🚀 5. Quickstart & Execution Guide

### Prerequisites
* **OS:** Linux x86_64 (Kernel 5.15+)
* **Graphics / Compute Driver:** Vulkan 1.3 capable driver (Mesa RADV, AMDVLK, or NVIDIA proprietary driver).
* **Python 3.8+** (for 100 Hz telemetry sampler).
* *(Optional)* `llama-bench` on your PATH if you wish to run automated relative comparison.

### Step 1: Probe Your Hardware Platform
Run the harness without arguments to verify that your GPU and compute backend are detected:
```bash
./scripts/run_benchmark.sh
```
*Sample Output:*
```text
🔍 Probing Hardware Platform... {"available_memory_mb":16384,"backend":"vulkan","device_name":"AMD Radeon AI PRO R9700"}
```

### Step 2: Run an Inference Benchmark
Supply any standard GGUF model file (e.g. Qwen, Llama, Mistral):
```bash
./scripts/run_benchmark.sh --model /path/to/your-model-q4_k_m.gguf
```
This command automatically:
1. Performs an in-VRAM memory headroom check to guarantee safety.
2. Starts the 100 Hz hardware power sampler in the background.
3. Executes prompt prefill and token generation.
4. Outputs the TTFT, hardware TPS, and total Joules consumed.

### Step 3: Run Relative Comparison vs llama.cpp
```bash
./scripts/run_benchmark.sh --model /path/to/your-model-q4_k_m.gguf --compare-llama
```

### Step 4: Run Context Scaling Stress Test
To test KV-cache memory scaling across 512, 2048, and 8192 context lengths:
```bash
./scripts/stress_contexts.sh /path/to/your-model-q4_k_m.gguf
```

---

## ⚡ 6. High-Frequency Telemetry Methodology

To measure energy efficiency without relying on estimated or vendor-biased software counters, the included sampler (`scripts/telemetry_rapl_smi.py`) executes concurrent hardware polling at 100 Hz (10 ms intervals):
* **AMD GPUs:** Reads `power1_average` from `/sys/class/drm/card*/device/hwmon/hwmon*` (microsecond-speed, world-readable sysfs).
* **NVIDIA GPUs:** Queries `nvidia-smi --query-gpu=power.draw`.
* **Intel CPUs:** Integrates Intel Running Average Power Limit (`RAPL`) MSR energy counters from `/sys/class/powercap/intel-rapl`.

Total energy is computed using numerical trapezoidal integration:
$$E_{\text{total}} = \sum_{i=1}^{N-1} \frac{P(t_i) + P(t_{i+1})}{2} \cdot (t_{i+1} - t_i)$$
$$\text{Energy per Token} = \frac{E_{\text{total}}}{\text{Total Tokens Generated}} \quad [\text{Joules/token}]$$

---

## 🤝 7. Community Contributions & Results Sharing

We encourage the community to run this harness across diverse hardware (AMD RDNA 3/4, NVIDIA Ada/Ampere, Intel Arc, etc.) and submit their findings:
* Open an issue or pull request with your `results/telemetry_*.csv` and `results/benchmark_*.json`.
* Help map the architectural landscape of sub-joule edge inference.

---

## 📜 8. License

The benchmark harness scripts, telemetry tools, documentation, and reference traces are released under the [MIT License](LICENSE).