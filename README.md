# Dotfiles — kmanisk

Managed with [chezmoi](https://www.chezmoi.io). One script sets up a fresh Windows machine from zero: package managers, tools, dotfiles, packages, extensions, and machine defaults.

---

## Quick Setup

Open **PowerShell** (admin or normal user — both work) and run:

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-RestMethod https://github.com/kmanisk/dotfiles/raw/master/AppData/Local/installer/setup.ps1 -OutFile $env:TEMP\setup.ps1; & $env:TEMP\setup.ps1"
```

That's it. The script handles everything in order:

1. Sets execution policy
2. Installs **Scoop** (with `-RunAsAdmin` if elevated)
3. Installs **Git** (required for Scoop buckets)
4. Adds all Scoop buckets
5. Installs **Python**, **aria2**, **gh**, **chezmoi**, **PowerShell 7**
6. Installs **Winget** and **Chocolatey**
7. Runs `chezmoi init --apply kmanisk` — clones this repo and applies dotfiles
8. chezmoi triggers `run_once_after_apply.ps1` which installs all packages
9. Installs VSCode / VSCodium extensions
10. Sets package pins, machine defaults, timezone, startup shortcuts

When prompted, choose a profile:
- `mini` — essential tools only
- `full` — everything including fonts, OSD, Spotify, WSL2

---

## Re-running / Updating

```powershell
# Apply dotfile changes
chezmoi apply

# Retry any failed steps (skips already-completed ones instantly)
.\setup.ps1

# Force everything to re-run from scratch
.\setup.ps1 -Reset
```

---

## Updating Packages

```powershell
scoop update *
choco upgrade all -y
winget upgrade --all
```

---

## Repository Layout

```
AppData/Local/installer/
    setup.ps1                  # Run once manually on a new machine
    run_once_after_apply.ps1   # Auto-run by chezmoi apply — installs packages
    packages.json              # Package lists (scoop/winget/choco, mini/full)
    vscode.json                # VSCode/VSCodium extension list
```

---

## Requirements

- Windows 10 (build 19041+) or Windows 11
- PowerShell 5.1 (built-in — no install needed)
- Internet connection
