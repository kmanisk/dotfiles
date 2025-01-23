<!--### For Normal User-->

# Dotfiles Managed by Chezmoi

This repository contains my dotfiles, managed using [chezmoi](https://www.chezmoi.io). Chezmoi makes it easy to manage and apply your dotfiles across multiple machines while keeping everything version-controlled.

## 🚀 Quick Setup

### Download and Run the Setup Script

To quickly set up your environment, follow these steps:

1. **Download the Setup Script**:
  ```bash
powershell -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force; & (New-Object System.Net.WebClient).DownloadFile('https://github.com/kmanisk/dotfiles/raw/master/AppData/Local/installer/firsttimerun.ps1', '$HOME\Downloads\firsttimerun.ps1'); . '$HOME\Downloads\firsttimerun.ps1'"
   ```
   <!--- Click the link below to download the `firsttimerun.ps1` script:-->
   <!--  [Download](https://github.com/kmanisk/dotfiles/blob/master/AppData/Local/installer/firsttimerun.ps1)-->

2. **Run the Script**:
   Open a PowerShell terminal and execute the script:

```bash
cd $env:USERPROFILE\Downloads; Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; ./firsttimerun.ps1
```
### Finally run this command
```bash
chezmoi init --apply kmanisk
```


