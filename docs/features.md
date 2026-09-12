# Optional Feature Flags

Features allow modular enablement or suppression of packages, daemons, and configuration directories based on the machine's intended workload.

---

## Feature Flags Reference

| Flag | Description | Default (Linux) | Default (Win) | Affected Paths |
|---|---|---|---|---|
| `gaming` | Steam, MangoHud, Gamemode, Gamescope | `true` | `true` | `.config/MangoHud/`, `packages/gaming.txt` |
| `development` | Compilers, runtimes, Git LFS, tooling | `true` | `true` | `packages/development.txt` |
| `asus_ctl` | ASUS TUF WMI, charge limits, supergfxctl | `true` (TUF) | `false` | `packages/asus.txt`, `asusd`, `supergfxd` |
| `bluetooth` | BlueZ daemon and Blueman integration | `true` | `true` | `bluetooth.service`, `packages/linux-core.txt` |
| `hyprland` | Hyprland compositor, Waybar, Mako, Rofi | `true` | `false` | `.config/hypr/`, `.config/waybar/`, etc. |
| `snapper` | Automated Btrfs pre/post snapshot hooks | `true` | `false` | `snapper-cleanup.timer`, `snap-pac` |
| `tearing_opt` | Low-latency tearing rules for competitive FPS | `true` | `false` | `appearance.lua`, `window_rules.lua` |

---

## Modifying Features

To toggle a feature for a machine, edit its entry in `.chezmoidata.toml`:

```toml
[machines.asus-tuf-f16.features]
gaming = true
development = true
asus_ctl = true
bluetooth = true
hyprland = true
snapper = true
hdr = false
tearing_opt = true
```

After modifying `.chezmoidata.toml`, apply the changes with:
```bash
chezmoi diff
chezmoi apply
```
