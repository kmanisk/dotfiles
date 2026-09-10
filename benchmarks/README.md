# System Idle Resource Benchmark & Baseline

This directory stores real hardware benchmarks comparing system resource utilization (CPU & RAM) when all user applications (browsers, Steam, editors, media players) are closed.

---

## Latest Test Results (Arch Linux + i3wm)

- **Date / Time**: September 11, 2026
- **Hardware**: ASUS TUF Gaming Laptop (Intel Core Raptor Lake + NVIDIA GeForce RTX 5050 Mobile)
- **OS**: Arch Linux (Kernel 7.2.3-1-cachyos)
- **Window Manager**: i3wm + picom (GLX)
- **Sampling Window**: 15 seconds (1.0s interval)

### Summary Metrics

| Metric | Linux Result (Arch + i3wm) | Windows 11 Baseline | Linux Advantage |
| :--- | :--- | :--- | :--- |
| **Average CPU Load** | **0.22%** *(Min: 0.12%, Max: 0.37%)* | **2.0% – 6.0%** | **~10x – 25x lower CPU load** |
| **RAM In-Use** | **2,427 MB (2.37 GB)** *(15.6%)* | **~4,500 – 5,500 MB** *(~30%–35%)* | **Frees ~2.4 – 3.0 GB more RAM** |
| **Available RAM** | **13,165 MB (12.86 GB)** | **~10,500 – 11,500 MB** | Massive headroom for CS2 / games |
| **Swap In-Use** | **173 MB** | Dynamic pagefile | No background disk paging |

### Top Memory Consumers at Clean Idle

```text
  - alacritty (terminal)   : 94.2 MB
  - Xorg (display server)  : 84.2 MB
  - i3 (window manager)    : 56.6 MB
  - picom (compositor)     : 42.7 MB
  - python3 (benchmark)    : 40.4 MB
  - blueman-applet         : 36.1 MB
```

Raw benchmark output log is available in [idle_benchmark_result.txt](./idle_benchmark_result.txt).

---

## How to Run the Benchmark

### On Linux (Arch / i3wm)
To run the automated 15-second benchmark with automatic app closing:
```bash
# Interactive mode (keeps current terminal open to view countdown):
idle-bench

# True 0-window mode (closes all windows including terminals, notifies when done):
idle-bench --full-idle
```

### On Windows
Open PowerShell as Administrator or normal user and run:
```powershell
powershell -ExecutionPolicy Bypass -File .\idle-bench.ps1
```
