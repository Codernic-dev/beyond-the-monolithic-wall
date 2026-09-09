#!/usr/bin/env bash
# ==============================================================================
# Beyond the Monolithic Wall: Deming Engine Benchmark Harness
# Author: Juan Tadeo Piana
# Copyright (c) 2026 Juan Tadeo Piana / Codernic. All rights reserved.
# Released under the terms of the Apache 2.0 / MIT License.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BIN_PATH="${REPO_ROOT}/bin/deming-eval"

MODEL_PATH=""
TOKENIZER_PATH=""
BACKEND="auto"
RUNNER="standard"
CONTEXT_SIZE="4096"
OUTPUT_DIR="${REPO_ROOT}/results"
COMPARE_LLAMA="0"

print_help() {
    cat <<EOF
Usage: ./scripts/run_benchmark.sh [OPTIONS]

Options:
    --model <PATH>            Path to GGUF model file (REQUIRED)
    --tokenizer <REPO/PATH>   Tokenizer repo or path (optional, extracted from GGUF by default)
    --backend <BACKEND>       Hardware backend: vulkan (default), hip, cuda, auto
    --runner <RUNNER>         Runner strategy: standard (default), medusa, eagle4
    --context-size <SIZE>     Context window size (default: 4096)
    --output-dir <DIR>        Directory for benchmark JSON/CSV logs (default: ./results)
    --compare-llama           Also run llama.cpp baseline (if installed) for relative speedup
    -h, --help                Show this help message

Examples:
    ./scripts/run_benchmark.sh --model ./models/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf
    ./scripts/run_benchmark.sh --model ./models/qwen2.5-coder-7b-instruct-q4_k_m.gguf --compare-llama
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --model)
            MODEL_PATH="$2"
            shift 2
            ;;
        --tokenizer)
            TOKENIZER_PATH="$2"
            shift 2
            ;;
        --backend)
            BACKEND="$2"
            shift 2
            ;;
        --runner)
            RUNNER="$2"
            shift 2
            ;;
        --context-size)
            CONTEXT_SIZE="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --compare-llama)
            COMPARE_LLAMA="1"
            shift 1
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

if [[ ! -x "${BIN_PATH}" ]]; then
    echo "Error: Release binary '${BIN_PATH}' not found or not executable."
    echo "Please check that bin/deming-eval is present."
    exit 1
fi

mkdir -p "${OUTPUT_DIR}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
TELEMETRY_CSV="${OUTPUT_DIR}/telemetry_${TIMESTAMP}.csv"
TELEMETRY_JSON="${OUTPUT_DIR}/telemetry_${TIMESTAMP}.json"
BENCH_JSON="${OUTPUT_DIR}/benchmark_${TIMESTAMP}.json"

echo "================================================================================"
echo " BEYOND THE MONOLITHIC WALL - EMPIRICAL BENCHMARK PROTOCOL"
echo " Author: Juan Tadeo Piana"
echo "================================================================================"

echo -n "Probing Hardware Platform... "
HW_PROBE="$("${BIN_PATH}" --probe-hardware)"
echo "${HW_PROBE}"

if [[ -z "${MODEL_PATH}" ]]; then
    echo "Notice: No --model specified. Hardware probe completed."
    echo "To execute an inference benchmark, supply a GGUF file:"
    echo "  ./scripts/run_benchmark.sh --model /path/to/model.gguf"
    exit 0
fi

if [[ ! -f "${MODEL_PATH}" ]]; then
    echo "Error: Model file '${MODEL_PATH}' does not exist."
    exit 1
fi

echo "Target Model: ${MODEL_PATH}"
echo "Backend: ${BACKEND} | Runner: ${RUNNER} | Context: ${CONTEXT_SIZE}"
echo "Telemetry: 100 Hz sampling -> ${TELEMETRY_CSV}"
echo "--------------------------------------------------------------------------------"

# Launch 100 Hz energy telemetry in background
python3 "${SCRIPT_DIR}/telemetry_rapl_smi.py" \
    --output-csv "${TELEMETRY_CSV}" \
    --output-json "${TELEMETRY_JSON}" \
    --interval-ms 10 &
TELEM_PID=$!

sleep 0.2

# Execute Deming Engine benchmark
echo "Executing Deming Engine Inference Run..."
DEMING_ARGS=(
    "--model-path" "${MODEL_PATH}"
    "--mode" "throughput"
    "--backend" "${BACKEND}"
    "--runner" "${RUNNER}"
    "--context-size" "${CONTEXT_SIZE}"
)

if [[ -n "${TOKENIZER_PATH}" ]]; then
    DEMING_ARGS+=("--tokenizer-repo" "${TOKENIZER_PATH}")
fi

"${BIN_PATH}" "${DEMING_ARGS[@]}"

# Stop telemetry
kill -TERM "${TELEM_PID}" 2>/dev/null || true
wait "${TELEM_PID}" 2>/dev/null || true

echo "--------------------------------------------------------------------------------"
echo "Telemetry trace captured in: ${TELEMETRY_CSV}"

# Optional comparison against llama.cpp
if [[ "${COMPARE_LLAMA}" == "1" ]]; then
    LLAMA_BENCH="$(which llama-bench 2>/dev/null || true)"
    if [[ -n "${LLAMA_BENCH}" ]]; then
        echo ""
        echo "================================================================================"
        echo " RUNNING LLAMA.CPP BASELINE COMPARISON"
        echo "================================================================================"
        "${LLAMA_BENCH}" -m "${MODEL_PATH}" -n 100 -p 512 || true
    else
        echo "Notice: llama-bench binary not found on PATH. Skipping llama.cpp baseline."
    fi
fi

echo ""
echo "Benchmark cycle completed successfully."
echo "Results logged to: ${OUTPUT_DIR}/"
