# Modular Package Manifests & Audit Inventory

This directory defines the package boundaries for the workstation fleet.

---

## 1. Declarative Package Sets (Active / Managed by Chezmoi)

These files define the intentional workstation requirements and are dynamically selected by `run_onchange_reconcile-packages.sh.tmpl` based on the target machine's enabled features:

| File | Purpose | Condition / Feature Flag |
|---|---|---|
| `common.txt` | Baseline CLI tools (git, ripgrep, btop, yazi, neovim, uv, etc.) | Core (All machines) |
| `linux-core.txt` | System tools (base-devel, btrfs-progs, snapper, networkmanager, ufw) | Linux Core |
| `i3.txt` | i3wm, Alacritty, Polybar, Dunst, Rofi, feh, X11 utilities | `features.i3 = true` |
| `gaming.txt` | Steam, Gamescope, Gamemode, Mangohud | `features.gaming = true` |
| `nvidia.txt` | NVIDIA dGPU drivers and 32-bit Vulkan/OpenCL libraries | `gpu_strategy = "hybrid-optimus-d3cold"` |
| `asus.txt` | ASUS ROG/TUF WMI tools (asusctl, supergfxctl) | `features.asus_ctl = true` |
| `audio.txt` | PipeWire, WirePlumber, audio firmware | `providers.audio` starts with `pipewire` |
| `development.txt` | Compilers, runtimes (Node.js, Python, ccache, mold) | `features.development = true` |
| `aur-explicit.txt` | Explicit AUR packages (antigravity-cli, bibata-cursor, xremap) | AUR-capable helper |

---

## 2. Audit Snapshots (Reference Only / Excluded from Auto-Install)

The following files are reference snapshots captured from the live machine for auditing and disaster recovery purposes. They are **never** installed automatically by Chezmoi:

- `pacman-explicit-official.txt`: Full raw dump of explicitly installed packages on the original system.
- `system-ecosystem-report.txt`: Ecosystem dependency audit.
- `cachyos-specific.txt`: Reference of packages provided exclusively by the CachyOS repositories.
