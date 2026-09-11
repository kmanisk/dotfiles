# CachyOS & Hyprland Gaming Performance Guidelines

## Hardware & Operating System Profile
- **OS / Kernel:** CachyOS Linux rolling (Kernel 7.2.x BORE / EEVDF scheduler, x86-64-v3)
- **Compositor:** Hyprland (Wayland) @ 1920x1200 / 1280x800 logical 165Hz
- **Hardware:** Intel Core i5-13450HX (13th Gen) | GeForce RTX 5050 Mobile + Intel Raptor Lake UHD
- **Storage / RAM:** Btrfs on NVMe / 16 GB DDR5 / Fish Shell / Alacritty & Kitty Terminals

## Architecture & Offloading Rules
- The Wayland desktop and daily GUI apps run on the integrated Intel Raptor Lake UHD iGPU for low idle power and heat.
- 3D games and heavy graphics run on the NVIDIA GeForce RTX 5050 Laptop GPU via `gamemoderun prime-run %command%`.
- Competitive games (`cs2`, `gamescope`, `steam_app_*`, `osu!`) have `immediate = true` tearing rules on dedicated Workspace 5.
- Gamescope 165Hz wrapper alias: `gscope`.

## Package Management & Safety Guardrails
- **Forbidden Commands:** NEVER run `pacman -Sy` (partial upgrade risk). Always run `pacman -Syu` or `cachyos-rate-mirrors`.
- **AUR Helper:** Use `paru` with CachyOS optimizations. Prefer packages from `[cachyos-v3]` and `[cachyos]` repositories before standard Arch repos or AUR.
- **Proton Selection:** Default to `proton-cachyos-slr` or `proton-cachyos` for Steam games.

## Filesystem & Scheduler Rules
- Btrfs Copy-on-Write (CoW) must remain disabled (`chattr +C`) on `~/.local/share/Steam/steamapps/common`, Wine prefixes, and VM images to prevent fragmentation and frametime stutters.
- `ananicy-cpp.service` must remain enabled and running for dynamic auto-nicing of game processes.

## Hyprland Configuration Guardrails
- ALWAYS consult official Hyprland wiki documentation (`~/.agents/skills/hyprland`) before making any Hyprland changes.
- Never use comma syntax in `hl.unbind()` — always use `+` syntax (e.g. `hl.unbind("SUPER + KEY")`).
- Avoid `hl.dsp.group.toggle()` in Hyprland 0.56.2 due to upstream C++ layout assertion crash bugs; use `hl.dsp.layout("togglesplit")`.
- Keep window rounding at 0 (flat corners), no blur on GUI/browsers, subtle blur on terminals only, and animations disabled for minimum input latency.
