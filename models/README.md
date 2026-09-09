# Models Directory

This directory is the dedicated storage location for GGUF model files evaluated by the Deming Engine.

The engine automatically discovers `.gguf` files located in this directory when running benchmarks without explicit CLI model flags.

---

## 1. Automated Model Download

To download the exact reference models evaluated in the preprint, run:

```bash
# Download the primary reference model (Qwen 2.5 Coder 1.5B Instruct Q4_K_M, ~986 MB)
./scripts/download_models.sh

# Or download the 7B reference model (Qwen 2.5 Coder 7B Instruct Q4_K_M, ~4.68 GB)
./scripts/download_models.sh --model 7b
```

---

## 2. Manual Download (Direct URLs)

If you prefer to download model files manually, place any of the following files in this directory:

### Qwen 2.5 Coder 1.5B Instruct (Q4_K_M) - Primary Reference
* **URL:** [https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF/resolve/main/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf](https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF/resolve/main/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf)
* **File size:** ~986 MB
* **Paper Metrics:** 261.02 tok/s, 0.19 ms TTFT, 0.84 J/token

### Qwen 2.5 Coder 7B Instruct (Q4_K_M) - Secondary Reference
* **URL:** [https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf)
* **File size:** ~4.68 GB
* **Paper Metrics:** 129.39 tok/s, 0.28 ms TTFT, 1.42 J/token

---

## 3. Custom Models

You can place any compatible standard GGUF model (Llama, Mistral, Gemma, Phi, etc.) in this directory. The engine will detect it automatically or you can point to it directly:

```bash
./scripts/run_benchmark.sh --model ./models/your-model.gguf
```
