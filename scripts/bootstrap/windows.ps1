<#
.SYNOPSIS
    Cross-Platform Dotfiles: Windows Workstation Bootstrap
.DESCRIPTION
    Installs Scoop, Git, Chezmoi, Age, and initializes workstation state.
#>

[CmdletBinding()]
param (
    [string]$DotfilesRepo = "https://github.com/kmanisk/dotfiles.git",
    [string]$Machine = "windows-workstation"
)

$ErrorActionPreference = "Stop"

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Starting Windows Workstation Bootstrap" -ForegroundColor Cyan
Write-Host " Target Machine: $Machine" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan

# 1. Execution Policy
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -ne "RemoteSigned" -and $currentPolicy -ne "Unrestricted") {
    Write-Host "==> [1/5] Setting ExecutionPolicy to RemoteSigned..." -ForegroundColor Yellow
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

# 2. Scoop Installation
Write-Host "==> [2/5] Checking Scoop package manager..." -ForegroundColor Green
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop..." -ForegroundColor Yellow
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "Scoop is already installed." -ForegroundColor Green
}

# 3. Core Packages via Scoop
Write-Host "==> [3/5] Ensuring Git, Chezmoi, and Age via Scoop..." -ForegroundColor Green
scoop install git chezmoi age 2>$null

# 4. Age Key Reminder
$keyPath = Join-Path $env:USERPROFILE ".config\chezmoi\key.txt"
Write-Host "==> [4/5] Checking Age encryption key..." -ForegroundColor Green
if (Test-Path $keyPath) {
    Write-Host "Age key found at $keyPath." -ForegroundColor Green
} else {
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "WARNING: Age private key not found at $keyPath" -ForegroundColor Yellow
    Write-Host "To decrypt age-encrypted secrets on Windows, place your age key at:" -ForegroundColor Yellow
    Write-Host "  $keyPath" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Yellow
}

# 5. Chezmoi Apply
Write-Host "==> [5/5] Initializing / Applying Chezmoi..." -ForegroundColor Green
chezmoi init --apply $DotfilesRepo

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Windows workstation bootstrap complete!" -ForegroundColor Cyan
Write-Host " Restart PowerShell or Windows Terminal to load your new environment." -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
