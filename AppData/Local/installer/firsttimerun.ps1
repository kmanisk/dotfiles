<#
.SYNOPSIS
  First-time system setup script for Windows with Scoop, Chocolatey, and Winget.
  Safe, modular, and portable — works for any user without hardcoded paths.
#>

#region Utility Functions

function Write-Section($msg) {
    Write-Host "`n======================================================" -ForegroundColor DarkGray
    Write-Host $msg -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor DarkGray
}

function Is-Admin {
    $identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

#endregion

#region Winget

function Install-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Section "Installing Winget..."
        Install-Script winget-install -Force -ErrorAction Stop
        winget-install -Force
    }
    else {
        Write-Host "Winget is already installed."
    }
}

#endregion

#region Scoop

function Install-Scoop {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Section "Installing Scoop..."
        Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)}"
    }
    else {
        Write-Host "Scoop is already installed."
    }

    # Wait for environment refresh
    Start-Sleep -Seconds 2

    # Buckets (excluding main/extras)
    $scoopBuckets = @(
        @{ Name = "versions"; URL = "https://github.com/ScoopInstaller/Versions" },
        @{ Name = "nerd-fonts"; URL = "https://github.com/matthewjberger/scoop-nerd-fonts" },
        @{ Name = "shemnei"; URL = "https://github.com/Shemnei/scoop-bucket" },
        @{ Name = "volllly"; URL = "https://github.com/volllly/scoop-bucket" }
    )

    # Add/repair buckets safely
    foreach ($bucket in $scoopBuckets) {
        $bucketPath = Join-Path $env:SCOOP "buckets\$($bucket.Name)"
        if (-not (Test-Path $bucketPath)) {
            Write-Host "Adding Scoop bucket: $($bucket.Name)"
            scoop bucket add $($bucket.Name) $($bucket.URL)
        }
        elseif (-not (Test-Path "$bucketPath\bucket\*.json")) {
            Write-Host "Bucket '$($bucket.Name)' appears broken. Re-adding..."
            scoop bucket rm $($bucket.Name) | Out-Null
            Remove-Item $bucketPath -Recurse -Force -ErrorAction SilentlyContinue
            scoop bucket add $($bucket.Name) $($bucket.URL)
        }
        else {
            Write-Host "Bucket '$($bucket.Name)' verified."
        }
    }
}

function Set-ScoopConfig {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Section "Configuring Scoop..."
        scoop config aria2-enabled true
        scoop config aria2-warning-enabled false
        Write-Host "Current Scoop Config:" -ForegroundColor Green
        scoop config show
    }
    else {
        Write-Host "Scoop not installed. Skipping configuration." -ForegroundColor Red
    }
}

#endregion

#region Chocolatey

function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Section "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    else {
        Write-Host "Chocolatey is already installed."
    }

    Write-Host "Configuring Chocolatey features..." -ForegroundColor Yellow
    choco feature enable -n allowGlobalConfirmation
    choco feature enable -n allowEmptyChecksums
    choco feature enable -n checksumFiles
}

#endregion

#region Aero Theme Installer

function Install-AeroTheme {
    $aeroPath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\appconfigs\mouse\Aero\Aero.inf"

    if (Test-Path $aeroPath) {
        Write-Section "Installing Aero Theme..."
        Start-Process "rundll32.exe" -ArgumentList "syssetup,SetupInfObjectInstallAction DefaultInstall 128 `"$aeroPath`"" -Verb RunAs -Wait
        Write-Host "Aero Theme installation completed."
    }
    else {
        Write-Host "Aero.inf not found at $aeroPath" -ForegroundColor Red
    }
}

#endregion

#region Core Packages

function Install-CorePackages {
    Write-Section "Installing Core Packages via Scoop..."
    $corePackages = @("aria2", "chezmoi", "git", "gh", "python")
    foreach ($pkg in $corePackages) {
        scoop install main/$pkg
    }

    Write-Section "Installing Microsoft Store Python..."
    winget install --id 9PNRBTZXMB4Z --accept-package-agreements --accept-source-agreements --silent --disable-interactivity
}

#endregion

#region Python & Pip Essentials

function pipInstallEssential {
    Write-Section "Installing Essential Python Packages..."
    $packages = @("gdown")

    if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
        Write-Host "Ensuring pip is available..."
        python -m ensurepip --upgrade
    }

    python -m pip install --upgrade pip

    foreach ($package in $packages) {
        if (-not (pip show $package -ErrorAction SilentlyContinue)) {
            Write-Host "Installing $package..."
            pip install $package --user
        }
        else {
            Write-Host "$package already installed."
        }
    }
}

#endregion

#region Visual C++ Runtimes

function Install-VisualCRuntimes {
    Write-Section "Installing Visual C++ Runtimes..."

    $tempPath = Join-Path ([System.IO.Path]::GetTempPath()) "firsttime"
    $downloadedZip = Join-Path $tempPath "Visual-C-Runtimes-All-in-One-Nov-2024.zip"

    if (-not (Test-Path $tempPath)) {
        New-Item -ItemType Directory -Path $tempPath | Out-Null
    }

    Set-Location $tempPath

    if (-not (Test-Path $downloadedZip)) {
        Write-Host "Downloading Visual C++ package..."
        gdown "https://drive.google.com/uc?export=download&id=1vrkXd9SfWCBJ8WdyWwICDTEoyYMoXjGA"
    }

    Write-Host "Extracting files..."
    Expand-Archive -Path $downloadedZip -DestinationPath $tempPath -Force

    $installBat = Join-Path $tempPath "install_all.bat"
    if (Test-Path $installBat) {
        Write-Host "Running installer..."
        Start-Process -FilePath $installBat -Wait
    }
    else {
        Write-Host "install_all.bat not found." -ForegroundColor Red
    }
}

#endregion

#region Main Routine

Write-Section "Starting Setup Script"

Install-Scoop
Set-ScoopConfig
Install-Chocolatey
Install-AeroTheme
Install-Winget
Install-CorePackages

$confirmation = Read-Host "Do you want to install essential Python packages and Visual C++ Runtimes? (y/n)"
if ($confirmation -eq 'y') {
    pipInstallEssential
    Install-VisualCRuntimes
}
else {
    Write-Host "Skipped optional packages." -ForegroundColor DarkYellow
}

Write-Section "Setup Completed Successfully 🎉"

#endregion
