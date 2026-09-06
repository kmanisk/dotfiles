## Bootstrap

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-RestMethod https://github.com/kmanisk/dotfiles/raw/master/AppData/Local/installer/setup.ps1 -OutFile $env:TEMP\setup.ps1; & $env:TEMP\setup.ps1"
```

## Common Commands

```powershell
# Sync dotfiles
chezmoi apply

# Update all packages (Scoop & Winget)
uall

# Check package status
pcheck
```

## Key Files

* `AppData/Local/installer/packages.json` — Package manifests (Scoop & Winget)
* `AppData/Local/installer/setup.ps1` — Bootstrap installer
* `readonly_Documents/PowerShell/` — PowerShell profile & custom aliases
