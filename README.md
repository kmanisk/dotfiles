# Dotfiles Managed by Chezmoi

This repository contains my dotfiles, managed using [chezmoi](https://www.chezmoi.io). Chezmoi makes it easy to manage and apply your dotfiles across multiple machines while keeping everything version-controlled.

## 🚀 Quick Setup

### Install Dotfiles

Run the following Install in New Machine:

### For Normal User
```bash
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```
### For Admin
```bash
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
```
### Finally run this command
```bash
chezmoi init --apply kmanisk
```
