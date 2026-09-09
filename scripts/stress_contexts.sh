#!/usr/bin/env bash
# ==============================================================================
# Multi-Context Stress Test Suite (512 / 2048 / 8192 Tokens)
# Author: Juan Tadeo Piana
# Copyright (c) 2026 Juan Tadeo Piana / Codernic. All rights reserved.
# Released under the terms of the Apache 2.0 / MIT License.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BIN_PATH="${REPO_ROOT}/bin/deming-eval"

MODEL_PATH="${1:-}"
if [[ -z "${MODEL_PATH}" ]]; then
    echo "Usage: $0 <path_to_gguf_model>"
    exit 1
fi

CONTEXTS=(512 2048 8192)

echo "================================================================================"
echo " CONTEXT LENGTH STRESS & KV-CACHE RETENTION EVALUATION"
echo " Author: Juan Tadeo Piana"
echo " Target Model: ${MODEL_PATH}"
echo " Contexts: 512, 2048, 8192 tokens"
echo "================================================================================"

for CTX in "${CONTEXTS[@]}"; do
    echo ""
    echo ">>> Testing Context Window: ${CTX} tokens"
    "${BIN_PATH}" \
        --model-path "${MODEL_PATH}" \
        --mode "throughput" \
        --context-size "${CTX}" \
        --kv-dtype "int8"
done

echo ""
echo "================================================================================"
echo "Context stress loop completed."
echo "================================================================================"
