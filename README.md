# Windows Dotfiles and System Configuration

Automated system bootstrapping, declarative package management, shell configuration, and developer environment management for Windows 10 and 11 using Chezmoi, PowerShell 7, Scoop, and Winget.

---

## Bootstrap Installation

Run the following command in PowerShell on a fresh Windows installation to initialize the environment:

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-RestMethod https://github.com/kmanisk/dotfiles/raw/master/AppData/Local/installer/setup.ps1 -OutFile $env:TEMP\setup.ps1; & $env:TEMP\setup.ps1"
```

The bootstrap installer handles the following automated tasks:
* Configures PowerShell Execution Policy (`RemoteSigned`).
* Installs and configures Scoop with parallel multi-connection downloads via `aria2`.
* Adds official and custom Scoop buckets (`main`, `extras`, `versions`, `java`, `nonportable`, `rilo`).
* Installs core developer tooling: Python, Git, GitHub CLI (`gh`), PowerShell 7 (`pwsh`), and Chezmoi.
* Pulls, initializes, and applies dotfiles state via Chezmoi.
* Performs declarative package installations defined in `packages.json` (Scoop & Winget).
* Installs developer fonts (Nerd Fonts and custom typography) directly into the user font registry.
* Installs and syncs VSCode / VSCodium extensions.
* Configures system defaults (Timezone, Clipboard, WSL2).

---

## Repository Structure

```
.
├── .chezmoiscripts/
│   └── run_once_after_apply.ps1     # Post-apply provisioning (fonts, packages, extensions)
├── AppData/
│   ├── Local/
│   │   └── installer/
│   │       ├── setup.ps1             # Main bootstrap installer script
│   │       ├── packages.json         # Declarative Scoop, Winget, and Font manifest
│   │       ├── vscode.json           # VSCode and VSCodium extension manifests
│   │       ├── Disable-ExplorerGroupBy.ps1  # CLI script to disable Explorer folder grouping
│   │       └── ExplorerGroupManager.ps1    # GUI utility for Explorer view customization
│   └── Roaming/
│       └── Zed/                      # Zed editor settings, keymaps, and AI configuration
├── dot_config/
│   ├── scoop/                        # Scoop configuration and bucket state
│   └── aria2/                        # Aria2 download acceleration profiles
├── readonly_Documents/
│   └── PowerShell/                   # PowerShell 7 profile and custom functions
└── README.md
```

---

## File Explorer Group By Manager

Windows File Explorer hardcodes default folder grouping templates across system directories (such as Downloads, Documents, and Pictures). This repository includes tools to manage or disable this behavior globally.

### CLI Utility: Disable-ExplorerGroupBy.ps1
Applies user-level `HKCU` registry overrides across all system `FolderTypes` templates to permanently disable grouping and clears legacy cached view bags.

```powershell
# Run from PowerShell
nogroup
```

### GUI Utility: ExplorerGroupManager.ps1
A standalone native Windows interface to switch between folder grouping modes in real time.

```powershell
# Launch GUI
groupgui
```

Available actions in the GUI:
* Disable Group By Globally (None)
* Restore Windows Default Grouping
* Group by Date Modified
* Group by Name (A-Z)
* Group by File Type
* Restart File Explorer

---

## Daily Management Commands

| Command | Purpose |
| :--- | :--- |
| `chezmoi apply` | Synchronize local configurations with the repository state |
| `uall` | Update all installed packages across Scoop and Winget |
| `pcheck` | Check status of managed packages and manifests |
| `nogroup` | Disable File Explorer folder grouping globally |
| `groupgui` | Launch the File Explorer View & Group Manager GUI |
| `scclear` | Purge Scoop download and package caches |

---

## Maintenance and Updates

To modify package manifests or profile configurations:
1. Update files in `~/.local/share/chezmoi/`.
2. Apply changes locally with `chezmoi apply`.
3. Commit and push changes to the upstream Git repository.
