#!/usr/bin/env bash
# ==============================================================================
# Reference Model Downloader
# Author: Juan Tadeo Piana
# Copyright (c) 2026 Juan Tadeo Piana / Codernic. All rights reserved.
# Released under the terms of the Apache 2.0 / MIT License.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MODELS_DIR="${REPO_ROOT}/models"

TARGET="1.5b"

print_help() {
    cat <<EOF
Usage: ./scripts/download_models.sh [OPTIONS]

Options:
    --model <1.5b|7b|all>   Which reference model to download (default: 1.5b)
    -h, --help              Show this help message

Models:
    1.5b  - Qwen 2.5 Coder 1.5B Instruct Q4_K_M (~986 MB) [Primary baseline]
    7b    - Qwen 2.5 Coder 7B Instruct Q4_K_M (~4.68 GB)
    all   - Download both reference models
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --model)
            TARGET="$2"
            shift 2
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

mkdir -p "${MODELS_DIR}"

download_file() {
    local url="$1"
    local dest="$2"
    local name="$3"

    if [[ -f "${dest}" ]]; then
        echo "Notice: '${name}' already exists at ${dest}. Skipping download."
        return 0
    fi

    echo "Downloading ${name}..."
    echo "Source: ${url}"
    echo "Destination: ${dest}"

    if command -v curl >/dev/null 2>&1; then
        curl -L --progress-bar -o "${dest}.tmp" "${url}"
        mv "${dest}.tmp" "${dest}"
    elif command -v wget >/dev/null 2>&1; then
        wget --show-progress -O "${dest}.tmp" "${url}"
        mv "${dest}.tmp" "${dest}"
    else
        echo "Error: Neither curl nor wget was found on your system."
        echo "Please install curl or wget, or download manually from:"
        echo "  ${url}"
        exit 1
    fi

    echo "Download completed: ${dest}"
}

URL_1_5B="https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF/resolve/main/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf"
DEST_1_5B="${MODELS_DIR}/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf"

URL_7B="https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf"
DEST_7B="${MODELS_DIR}/qwen2.5-coder-7b-instruct-q4_k_m.gguf"

case "${TARGET}" in
    1.5b|1.5B)
        download_file "${URL_1_5B}" "${DEST_1_5B}" "Qwen 2.5 Coder 1.5B Instruct Q4_K_M"
        ;;
    7b|7B)
        download_file "${URL_7B}" "${DEST_7B}" "Qwen 2.5 Coder 7B Instruct Q4_K_M"
        ;;
    all|ALL)
        download_file "${URL_1_5B}" "${DEST_1_5B}" "Qwen 2.5 Coder 1.5B Instruct Q4_K_M"
        download_file "${URL_7B}" "${DEST_7B}" "Qwen 2.5 Coder 7B Instruct Q4_K_M"
        ;;
    *)
        echo "Error: Unknown model target '${TARGET}'. Use '1.5b', '7b', or 'all'."
        exit 1
        ;;
esac

echo ""
echo "Model setup complete. You can now execute:"
echo "  ./scripts/run_benchmark.sh"
