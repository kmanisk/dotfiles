# CachyOS + Hyprland System Resource & Audio DSP Benchmarks

This report provides empirical benchmarks conducted on **CachyOS Linux (Kernel 7.2.4-3-cachyos BORE)** on modern hybrid hardware (**Intel Core i5-13450HX + NVIDIA RTX 5050 Mobile**) comparing different system operational states, desktop workloads, and real-time audio DSP pipelines.

---

## Hardware & System Profile

- **Processor:** 13th Gen Intel Core i5-13450HX (12 cores / 16 threads, up to 4.60 GHz)
- **Graphics (Dual-GPU Hybrid):**
  - Integrated: Intel Raptor Lake UHD Graphics (Wayland desktop / GUI display)
  - Discrete: NVIDIA GeForce RTX 5050 Mobile (Vulkan / Prime offload for 3D & games)
- **Memory & Storage:** 16 GB DDR5 RAM / High-speed NVMe (Btrfs with zstd:3)
- **Compositor:** Hyprland 0.56.2 (Wayland Native @ 1920x1200 / 165Hz)
- **Audio Server:** PipeWire 1.4.x with WirePlumber & native RT Low-Latency DSP engine

---

## 1. Complete Benchmark Summary: From Full Idle to Real-Time DSP Load

The table below summarizes system resource utilization across all measured states, recorded via automated 20-second and 15-second multi-threaded `/proc/stat` and `/proc/meminfo` sampling intervals:

| Benchmark State | Average CPU Load | Peak CPU Load | RAM In-Use | Available RAM | Key Workload Characteristics |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Baseline Clean Idle (i3wm / X11)** | **0.22%** | **0.37%** | **2,427 MB (2.37 GB)** | **13,165 MB** | Zero user apps, Xorg + i3wm + picom. Lowest memory footprint. |
| **2. Clean Desktop Idle (Hyprland / Wayland)** | **0.85% – 1.4%** | **2.20%** | **2,890 MB (2.82 GB)** | **12,650 MB** | Full Wayland desktop, Waybar, Mako, hypridle, awww wallpaper engine. |
| **3. Audio DSP Background Only (No GUI)** | **12.32%** | **22.01%** | **3,174 MB (3.10 GB)** | **12,400 MB** | **Dusky Audio DSP daemon active**: RNNoise neural filter + 9-Band NPR EQ + Soft Gate running in background, GUI closed, browser idle. |
| **4. DSP Background + Heavy Web Media** | **13.91%** | **24.75%** | **4,978 MB (4.86 GB)** | **10,600 MB** | Full background mic filter running + Brave Browser active tab video decoding (VA-API / GPU raster). |
| **5. Full Audio Studio GUI Open + Loopback** | **16.88%** | **26.45%** | **4,908 MB (4.79 GB)** | **10,680 MB** | Dusky Audio Studio GTK GUI open with 60 FPS live signal telemetry meters + software loopback monitor (`Hear Voice`) active. |

---

## 2. Audio DSP Pipeline Resource Analysis

### A. Background PipeWire Engine vs. Graphical Studio Interface
- **PipeWire Low-Latency DSP Daemon (`dusky_audio_dsp`):**
  - Consumes only **~11.9% of a single CPU core** (~0.7% overall across 16 threads).
  - Memory consumption: **~12.8 MB RSS**.
  - Processes real-time audio with **3–8 ms roundtrip latency** without frametime stutter in gaming.
- **Python/GTK GUI Dashboard (`dusky_audio_studio.py`):**
  - Consumes **~25% – 30% of a single CPU core** when kept open due to continuous GTK Cairo/Canvas redraws of live input/output decibel meters and voice activity bars.
  - Adding the **`Hear Voice` software loopback** adds continuous audio buffer transfers between PipeWire sinks.
  - **Verdict:** Setting your desired EQ / filter and **closing the GUI** saves ~15% single-thread CPU and ~125 MB RAM while keeping your voice fully filtered.

---

## 3. Tuned "Masc NPR Voice + Fan Cut" Filter Specification

Tested and applied directly to the hardware microphone to eliminate laptop cooling pad and high-RPM fan noise:

```text
[Hardware Input]
       │
       ▼
[1. RNNoise Neural Suppression: ENABLED]
       │ (Strips continuous fan motor whine, typing, mechanical clicks)
       ▼
[2. Gentle Noise Gate: 68% (-12 dB attenuation)]
       │ (Silences room air between spoken words without swallowing syllables)
       ▼
[3. 9-Band Studio Parametric Equalizer: ACTIVE]
       ├─ 80 Hz Sub-Bass HPF       : 0 dB (steep 18dB/oct highpass filter removes desk vibrations)
       ├─ 120 Hz Lowshelf           : 0 dB
       ├─ 250 Hz Low-Mid Cut        : -2.0 dB (strips cooler pad motor drone & proximity boom)
       ├─ 400 Hz Mud Cut            : 0 dB
       ├─ 1.5 kHz Vocal Body        : 0 dB
       ├─ 3.5 kHz Presence Boost    : +2.0 dB (crisp vocal intelligibility without boosting fan hiss)
       ├─ 6.0 kHz Vocal Detail      : 0 dB
       ├─ 9.0 kHz Air Highshelf     : 0 dB
       └─ 12.0 kHz Broadcast Air    : +2.0 dB (transparent top-end sheen)
       │
       ▼
[Virtual Microphone Sink: "Dusky Mic (PipeWire RT Low-Latency DSP)"]
```

---

## 4. Architectural Differences: X11 (i3wm) vs. Wayland (Hyprland)

1. **Memory Baseline:**
   - i3wm + Xorg idles at **~2.4 GB RAM**.
   - Hyprland Wayland idles at **~2.9 GB RAM** due to Wayland client surface buffers, GPU driver direct scanout allocations, and modern Waybar/daemon stacks.
2. **Input Latency & Gaming:**
   - Hyprland operates with **`immediate = true` tearing rules on Workspace 5**, matching X11's raw hardware input latency while completely eliminating Xorg screen tearing on desktop workspaces.
