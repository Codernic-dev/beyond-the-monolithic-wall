# Beyond the Monolithic Wall: Deming Engine Benchmark Suite

[![Preprint Companion](https://img.shields.io/badge/Preprint-Companion_Artifact-blue.svg)](https://github.com/Codernic-dev/beyond-the-monolithic-wall)
[![License](https://img.shields.io/badge/License-Apache_2.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux_x86__64-lightgrey.svg)]()
[![Compute](https://img.shields.io/badge/Compute-Vulkan_1.3_%7C_HIP-navy.svg)]()

> **Evaluation Harness & Reproducibility Suite for the Research Preprint:**  
> *"Beyond the Monolithic Wall: Sub-Joule Reasoning and Architectural Efficiency in Edge-Native Heterogeneous Transformers"*  
> **Author:** Juan Tadeo Piana (Codernic)

---

## 1. Overview and Research Context

As Large Language Models scale in parameter count, local edge deployment encounters fundamental hardware bottlenecks: memory bandwidth saturation, quadratic $O(N^2)$ KV-cache explosion, and unsustainable thermal power dissipation.

The **Deming Engine** is a high-efficiency inference runtime engineered in bare-metal Rust. It addresses monolithic execution overhead through:
1. **Paged INT8 KV-Cache and Sub-Buffers:** Reducing context memory consumption by up to **98.6%**.
2. **Sub-Millisecond Time-To-First-Token (TTFT):** Achieving prefill restoration in **0.19 ms** on edge hardware.
3. **Sub-Joule Energy Footprint:** Achieving **0.84 Joules per token** at high throughput via optimized compute shaders and asynchronous queues.

This repository provides an **independent, reproducible evaluation harness**. It enables researchers and developers to verify the empirical throughput, latency, and energy metrics reported in the paper on their own hardware.

---

## 2. Author's Statement and Empirical Practitioner Disclaimer

### Practitioner Disclosure
> *I am Juan Tadeo Piana, an independent software developer with 26 years of hands-on experience in low-level systems engineering. I hold no university degrees or formal academic credentials in theoretical mathematics, engineering, or computer science; I am neither an academic researcher nor an institutional theorist. The ground truth of this research resides strictly in physical bare-metal silicon telemetry (Intel RAPL MSR and AMD ROCm SMI sampled at 100 Hz) and verified shader execution. Mathematical formulations are descriptive models provided to share systems findings with the scientific community.*

### Understanding Hardware Differences and Relative Speedup
Because GPU architectures, memory bus widths, and compute unit configurations vary across hardware platforms, **absolute Tokens Per Second (TPS) will naturally vary across different machines**:
* An NVIDIA RTX 4090, an AMD Radeon AI PRO R9700, or an Apple Silicon M-series chip each have distinct silicon characteristics and peak compute capabilities.
* **The definitive portable metric is RELATIVE EFFICIENCY:**
  $$\text{Relative Speedup} = \frac{\text{TPS}_{\text{Deming}}}{\text{TPS}_{\text{llama.cpp}}}$$
  $$\text{Energy Reduction} = 1 - \frac{\text{Joules/token}_{\text{Deming}}}{\text{Joules/token}_{\text{Baseline}}}$$
* To enable objective comparative evaluation, this harness includes the `--compare-llama` option, which executes `llama-bench` on the identical model and prompt on your machine to report your local speedup ratio.

---

## 3. Reference Baseline (Paper Ground Truth)

All metrics reported in Section 5 of the preprint were measured on the following dedicated testbed:

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

*Raw reference telemetry logs and JSON summaries are available in [`traces/`](traces/).*

---

## 4. Repository Structure and Artifacts

```text
beyond-the-monolithic-wall/
├── bin/
│   ├── deming-eval                # Stripped standalone release binary (Linux x86_64)
│   └── README.md                  # Binary artifact specifications and notes
├── config/
│   └── engine.yaml                # Canonical Deming Engine configuration file
├── models/
│   ├── README.md                  # Model placement guide and download URLs
│   └── .gitkeep                   # Directory placeholder (weights git-ignored)
├── scripts/
│   ├── download_models.sh         # 1-command reference model downloader
│   ├── run_benchmark.sh           # Main benchmark execution script
│   ├── stress_contexts.sh         # Multi-context stress test (512 / 2048 / 8192)
│   └── telemetry_rapl_smi.py      # 100 Hz GPU + CPU energy & power telemetry sampler
├── traces/
│   ├── reference_run_1.5b.json    # Reference metrics for 1.5B model from paper
│   ├── reference_run_7b.json      # Reference metrics for 7B model from paper
│   └── reference_telemetry_r9700.csv # Real 100 Hz power dissipation profile (37-52W)
├── LICENSE                        # Apache 2.0 License
└── README.md                      # Documentation and evaluation guide
```

### Note on the Evaluation Binary (`bin/deming-eval`)
The executable `bin/deming-eval` is a pre-compiled, stripped 64-bit ELF binary executable for Linux x86_64. As a compiled binary artifact, it contains no plain-text source code. It is provided to enable immediate, direct evaluation of the Deming Engine without proprietary toolchain requirements.

---

## 5. Configuration Management (`config/engine.yaml`)

The Deming Engine reads its runtime parameters from `config/engine.yaml`:

```yaml
inference:
  backend: "vulkan"            # "vulkan" (default), "hip" (ROCm), "cuda", or "auto"
  runner_strategy: "standard"  # "standard", "medusa", or "eagle4"
  kv_cache:
    kv_dtype: "int8"           # INT8 Paged Cache (98.6% memory reduction)
    max_context_tokens: 4096

paths:
  models_dir: "./models"       # Directory where GGUF weights are located
  default_model: "./models/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf"
  results_dir: "./results"     # Destination for telemetry logs and benchmark results

telemetry:
  sampling_interval_ms: 10     # 10 ms interval = 100 Hz sampling frequency
```

---

## 6. Quickstart and Execution Guide

### Prerequisites
* **Operating System:** Linux x86_64 (Kernel 5.15+)
* **Graphics / Compute Driver:** Vulkan 1.3 capable driver (Mesa RADV, AMDVLK, or NVIDIA proprietary driver).
* **Python 3.8+** (for the 100 Hz telemetry sampler).
* *(Optional)* `llama-bench` on your PATH for automated baseline comparison.

### Step 1: Probe Your Hardware Platform
Run the harness without arguments to verify that your GPU and compute backend are detected:
```bash
./scripts/run_benchmark.sh
```
*Sample output:*
```text
Probing Hardware Platform... {"available_memory_mb":16384,"backend":"vulkan","device_name":"AMD Radeon AI PRO R9700"}
```

### Step 2: Download the Reference Model
Download the primary reference model (Qwen 2.5 Coder 1.5B Instruct Q4_K_M, ~986 MB) with 1 command:
```bash
./scripts/download_models.sh
```
*To download the 7B model instead, run `./scripts/download_models.sh --model 7b`.*

### Step 3: Run the Inference Benchmark
Once a model is placed in `./models/`, simply execute:
```bash
./scripts/run_benchmark.sh
```
*The script automatically detects the model in `./models/` and loads parameters from `config/engine.yaml`.*

You can also specify an explicit model file from any location:
```bash
./scripts/run_benchmark.sh --model /path/to/any-model.gguf
```

### Step 4: Run Relative Comparison vs llama.cpp
To measure your machine's relative speedup ratio against `llama.cpp`:
```bash
./scripts/run_benchmark.sh --compare-llama
```

### Step 5: Run Context Scaling Stress Test
To evaluate KV-cache memory scaling across 512, 2048, and 8192 context lengths:
```bash
./scripts/stress_contexts.sh ./models/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf
```

---

## 7. High-Frequency Telemetry Methodology

To measure energy efficiency without relying on estimated or vendor-biased software counters, the included sampler (`scripts/telemetry_rapl_smi.py`) executes concurrent hardware polling at 100 Hz (10 ms intervals):
* **AMD GPUs:** Reads `power1_average` from `/sys/class/drm/card*/device/hwmon/hwmon*` (microsecond-speed sysfs interface).
* **NVIDIA GPUs:** Queries `nvidia-smi --query-gpu=power.draw`.
* **Intel CPUs:** Integrates Intel Running Average Power Limit (`RAPL`) MSR energy counters from `/sys/class/powercap/intel-rapl`.

Total energy is computed via numerical trapezoidal integration:
$$E_{\text{total}} = \sum_{i=1}^{N-1} \frac{P(t_i) + P(t_{i+1})}{2} \cdot (t_{i+1} - t_i)$$
$$\text{Energy per Token} = \frac{E_{\text{total}}}{\text{Total Tokens Generated}} \quad [\text{Joules/token}]$$

---

## 8. Community Contributions and Verification

Researchers and practitioners are invited to execute this harness across diverse hardware configurations (AMD RDNA 3/4, NVIDIA Ada/Ampere, Intel Arc, etc.) and share their telemetry traces:
* Open an issue or pull request with your `results/telemetry_*.csv` and `results/benchmark_*.json`.
* Contribute to empirical mapping of edge-native sub-joule transformer execution.

---

## 9. License and Citation

* **Code and Harness:** Released under the [Apache License 2.0](LICENSE).
* **Preprint Citation:**
```bibtex
@article{piana2026beyond,
  title={Beyond the Monolithic Wall: Sub-Joule Reasoning and Architectural Efficiency in Edge-Native Heterogeneous Transformers},
  author={Piana, Juan Tadeo},
  journal={Preprint},
  year={2026}
}
```