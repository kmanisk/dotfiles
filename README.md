# Dotfiles Managed by Chezmoi

This repository contains my dotfiles, managed using [chezmoi](https://www.chezmoi.io). Chezmoi makes it easy to manage and apply your dotfiles across multiple machines while keeping everything version-controlled.

## 🚀 Quick Setup

## Prerequisites

Need to install dependency(scoop and git):

### For Normal User
```bash
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```
### For Admin
```bash
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
scoop install main/chezmoi
```

```
winget install twpayne.chezmoi
winget install Git.Git
winget install -e --id GitHub.cli
```

### Configure Git
```

git config --global user.name "kmanisk" 
git config --global user.email "youremail@example.com"
gh auth login
```

### Finally run this command
```bash
chezmoi init --apply kmanisk
```


