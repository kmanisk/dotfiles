<!--### For Normal User-->

# Dotfiles Managed by Chezmoi

This repository contains my dotfiles, managed using [chezmoi](https://www.chezmoi.io). Chezmoi makes it easy to manage and apply your dotfiles across multiple machines while keeping everything version-controlled.

## 🚀 Quick Setup

### Download and Run the Setup Script

To quickly set up your environment, follow these steps:

1. **Download the Setup Script**:
   - Click the link below to download the `firsttimerun.ps1` script:
     [Download firsttimerun.ps1](https://raw.githubusercontent.com/kmanisk/dotfiles/refs/heads/master/AppData/Local/installer/firsttimerun.ps1)

2. **Run the Script**:
   Open a PowerShell terminal and execute the script:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ./firsttimerun.ps1
<!--```bash-->
<!--Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser-->
<!--Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression-->
<!--```-->
<!--### For Admin-->
<!--```bash-->
<!--Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser-->
<!--iex "& {$(irm get.scoop.sh)} -RunAsAdmin"-->
<!--scoop install main/chezmoi-->
<!--```-->
<!--### For Winget Users-->
<!---->
<!--```-->
<!--winget install twpayne.chezmoi-->
<!--winget install Git.Git-->
<!--winget install -e --id GitHub.cli-->
<!--```-->
<!---->
<!--### Configure Git-->
<!--```-->
<!---->
<!--git config --global user.name "kmanisk" -->
<!--git config --global user.email "youremail@example.com"-->
<!--gh auth login-->
<!--```-->

### Finally run this command
```bash
chezmoi init --apply kmanisk
```


