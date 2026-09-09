#!/usr/bin/env python3
"""
Deming Engine 100 Hz Hardware Energy & Power Telemetry Sampler
Part of 'Beyond the Monolithic Wall' Evaluation Suite

Author: Juan Tadeo Piana
Copyright (c) 2026 Juan Tadeo Piana / Codernic. All rights reserved.
Released under the terms of the Apache 2.0 / MIT License.

Measures real-time GPU and CPU power dissipation at up to 100 Hz (10 ms interval).
Computes exact integrated energy in Joules and Energy per Token (J/tok).
"""

import sys
import os
import time
import glob
import argparse
import signal
import json
import subprocess

stop_sampling = False

def sig_handler(signum, frame):
    global stop_sampling
    stop_sampling = True

signal.signal(signal.SIGINT, sig_handler)
signal.signal(signal.SIGTERM, sig_handler)

def find_amd_hwmon():
    """Finds sysfs hwmon path for AMD Radeon GPU."""
    candidates = glob.glob("/sys/class/drm/card*/device/hwmon/hwmon*")
    for cand in candidates:
        power_path = os.path.join(cand, "power1_average")
        if os.path.exists(power_path):
            try:
                with open(power_path, "r") as f:
                    _ = float(f.read().strip())
                return cand
            except Exception:
                pass
    return None

def find_rapl_energy():
    """Finds Intel RAPL sysfs energy_uj file."""
    path = "/sys/class/powercap/intel-rapl:0/energy_uj"
    if os.path.exists(path):
        try:
            with open(path, "r") as f:
                _ = int(f.read().strip())
            return path
        except Exception:
            return None
    return None

def main():
    parser = argparse.ArgumentParser(description="100 Hz Hardware Telemetry Sampler for Deming Engine")
    parser.add_argument("--output-csv", default="telemetry_trace.csv", help="Path to write output CSV trace")
    parser.add_argument("--output-json", default=None, help="Optional path to write summary JSON")
    parser.add_argument("--interval-ms", type=float, default=10.0, help="Sampling interval in milliseconds (default: 10 ms = 100 Hz)")
    parser.add_argument("--tokens", type=int, default=None, help="Number of generated tokens for J/token computation")
    parser.add_argument("--cmd", nargs=argparse.REMAINDER, help="Optional command to execute and profile concurrently")
    args = parser.parse_args()

    amd_hwmon = find_amd_hwmon()
    rapl_path = find_rapl_energy()
    has_nvidia = False

    if not amd_hwmon:
        try:
            res = subprocess.run(["nvidia-smi", "--query-gpu=power.draw", "--format=csv,noheader,nounits"],
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if res.returncode == 0:
                has_nvidia = True
        except Exception:
            pass

    print("[Telemetry] Hardware interfaces detected:")
    print(f"  - AMD Sysfs Hwmon: {'ACTIVE (' + amd_hwmon + ')' if amd_hwmon else 'Not found'}")
    print(f"  - Intel RAPL:      {'ACTIVE (' + rapl_path + ')' if rapl_path else 'Restricted / Not found'}")
    print(f"  - NVIDIA SMI:      {'ACTIVE' if has_nvidia else 'Not found'}")

    os.makedirs(os.path.dirname(os.path.abspath(args.output_csv)), exist_ok=True)
    f_csv = open(args.output_csv, "w", buffering=1)
    f_csv.write("timestamp_epoch_s,elapsed_ms,gpu_power_w,cpu_power_w,total_power_w,gpu_temp_c\n")

    proc = None
    if args.cmd:
        print(f"[Telemetry] Launching child process: {' '.join(args.cmd)}")
        proc = subprocess.Popen(args.cmd)

    start_time = time.time()
    last_rapl_uj = None
    last_rapl_t = None
    if rapl_path:
        try:
            with open(rapl_path, "r") as f:
                last_rapl_uj = int(f.read().strip())
            last_rapl_t = time.time()
        except Exception:
            rapl_path = None

    samples = []
    interval_s = max(0.001, args.interval_ms / 1000.0)

    try:
        while not stop_sampling:
            now = time.time()
            elapsed_ms = (now - start_time) * 1000.0

            # 1. Sample GPU
            gpu_w = 0.0
            gpu_temp = 0.0
            if amd_hwmon:
                try:
                    with open(os.path.join(amd_hwmon, "power1_average"), "r") as f:
                        gpu_w = float(f.read().strip()) / 1_000_000.0
                    temp_path = os.path.join(amd_hwmon, "temp1_input")
                    if os.path.exists(temp_path):
                        with open(temp_path, "r") as f:
                            gpu_temp = float(f.read().strip()) / 1000.0
                except Exception:
                    pass
            elif has_nvidia:
                try:
                    res = subprocess.run(["nvidia-smi", "--query-gpu=power.draw,temperature.gpu", "--format=csv,noheader,nounits"],
                                         stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                    if res.returncode == 0:
                        parts = res.stdout.strip().split(",")
                        gpu_w = float(parts[0].strip())
                        if len(parts) > 1:
                            gpu_temp = float(parts[1].strip())
                except Exception:
                    pass

            # 2. Sample CPU via RAPL if readable
            cpu_w = 0.0
            if rapl_path and last_rapl_uj is not None:
                try:
                    with open(rapl_path, "r") as f:
                        current_uj = int(f.read().strip())
                    dt = now - last_rapl_t
                    if dt > 0:
                        delta_uj = current_uj - last_rapl_uj
                        if delta_uj < 0:
                            delta_uj = 0
                        cpu_w = (delta_uj / 1_000_000.0) / dt
                    last_rapl_uj = current_uj
                    last_rapl_t = now
                except Exception:
                    pass

            total_w = gpu_w + cpu_w
            f_csv.write(f"{now:.4f},{elapsed_ms:.2f},{gpu_w:.2f},{cpu_w:.2f},{total_w:.2f},{gpu_temp:.1f}\n")
            samples.append((now, gpu_w, cpu_w, total_w))

            if proc:
                ret = proc.poll()
                if ret is not None:
                    break

            time.sleep(interval_s)
    finally:
        f_csv.close()

    total_duration_s = time.time() - start_time
    if len(samples) > 1:
        total_joules = 0.0
        gpu_joules = 0.0
        for i in range(1, len(samples)):
            dt = samples[i][0] - samples[i-1][0]
            gpu_joules += 0.5 * (samples[i][1] + samples[i-1][1]) * dt
            total_joules += 0.5 * (samples[i][3] + samples[i-1][3]) * dt

        avg_power = total_joules / total_duration_s if total_duration_s > 0 else 0.0
        peak_power = max(s[3] for s in samples)
        peak_gpu = max(s[1] for s in samples)

        print("\n+--------------------------------------------------------------------------------+")
        print("| [ENERGY & POWER TELEMETRY SUMMARY - 100 HZ LOG]                                |")
        print("+--------------------------------------------------------------------------------+")
        print(f"| Duration:            {total_duration_s:>12.2f} s                                     |")
        print(f"| Samples Captured:    {len(samples):>12}                                           |")
        print(f"| Total Energy:        {total_joules:>12.2f} Joules (J)                             |")
        print(f"| GPU Energy:          {gpu_joules:>12.2f} Joules (J)                             |")
        print(f"| Average Total Power: {avg_power:>12.2f} W                                      |")
        print(f"| Peak System Power:   {peak_power:>12.2f} W                                      |")
        print(f"| Peak GPU Power:      {peak_gpu:>12.2f} W                                      |")

        j_per_tok = None
        if args.tokens and args.tokens > 0:
            j_per_tok = total_joules / args.tokens
            print(f"| Generated Tokens:    {args.tokens:>12}                                           |")
            print(f"| Energy Per Token:    {j_per_tok:>12.4f} Joules / token (J/tok)                    |")
        print("+--------------------------------------------------------------------------------+\n")

        summary = {
            "author": "Juan Tadeo Piana",
            "duration_s": total_duration_s,
            "samples_count": len(samples),
            "total_energy_joules": total_joules,
            "gpu_energy_joules": gpu_joules,
            "avg_power_w": avg_power,
            "peak_power_w": peak_power,
            "peak_gpu_power_w": peak_gpu,
            "tokens": args.tokens,
            "joules_per_token": j_per_tok
        }

        if args.output_json:
            with open(args.output_json, "w") as fj:
                json.dump(summary, fj, indent=2)

if __name__ == "__main__":
    main()
