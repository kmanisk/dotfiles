<#
.SYNOPSIS
First-time system setup script for Windows using Scoop, Chocolatey, Winget.
Fully self-contained. No Microsoft Store dependency.
#>

#region Utility Functions

function Write-Section($msg) {
    Write-Host "`n======================================================" -ForegroundColor DarkGray
    Write-Host $msg -ForegroundColor Cyan
    Write-Host "======================================================`n" -ForegroundColor DarkGray
}

function Refresh-Environment {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH","User")
}

#endregion

#region Scoop Install (CRITICAL FIX)

function Install-Scoop {

    Write-Section "Installing Scoop"

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {

        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

    }

    # Guarantee Scoop env exists NOW
    $env:SCOOP = "$HOME\scoop"
    $env:PATH = "$HOME\scoop\shims;$env:PATH"

    Refresh-Environment

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        throw "Scoop installation failed"
    }

    Write-Host "Scoop ready" -ForegroundColor Green
}

#endregion

#region Scoop Buckets

function Install-ScoopBuckets {

    Write-Section "Installing Scoop Buckets"

    $buckets = @(
        "main",
        "extras",
        "versions",
        "nerd-fonts",
        "shemnei",
        "volllly"
    )

    foreach ($bucket in $buckets) {

        $bucketPath = "$HOME\scoop\buckets\$bucket"

        if (-not (Test-Path $bucketPath)) {

            Write-Host "Adding bucket: $bucket"
            scoop bucket add $bucket

        } else {

            Write-Host "Bucket exists: $bucket"

        }
    }
}

#endregion

#region Core Packages (FIXED)

function Install-CorePackages {

    Write-Section "Installing Core Packages via Scoop"

    $packages = @(
        "git",
        "aria2",
        "chezmoi",
        "gh",
        "python"
    )

    foreach ($pkg in $packages) {

        if (-not (scoop list | Select-String "^$pkg ")) {

            Write-Host "Installing $pkg"
            scoop install $pkg

        } else {

            Write-Host "$pkg already installed"

        }
    }

    # CRITICAL FIX: guarantee python usable immediately

    $env:PATH = "$HOME\scoop\apps\python\current;$env:PATH"

    if (-not (Test-Path "$HOME\scoop\apps\python\current\python.exe")) {
        throw "Scoop Python install failed"
    }

    Write-Host "Python ready via Scoop" -ForegroundColor Green
}

#endregion

#region Chocolatey

function Install-Chocolatey {

    Write-Section "Installing Chocolatey"

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {

        Set-ExecutionPolicy Bypass -Scope Process -Force

        Invoke-Expression (
            (New-Object Net.WebClient).DownloadString(
                "https://chocolatey.org/install.ps1"
            )
        )

    }

    Refresh-Environment

}

#endregion

#region Winget

function Install-Winget {

    Write-Section "Checking Winget"

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {

        Write-Host "Winget not present. Install manually if needed."

    } else {

        Write-Host "Winget ready"

    }

}

#endregion

#region Python Pip Essentials (FIXED)

function pipInstallEssential {

    Write-Section "Installing Python Essentials"

    $python = "$HOME\scoop\apps\python\current\python.exe"

    if (-not (Test-Path $python)) {
        throw "Python not found"
    }

    & $python -m pip install --upgrade pip

    $packages = @("gdown")

    foreach ($pkg in $packages) {

        & $python -m pip install $pkg --user

    }

}

#endregion

#region Main

Write-Section "Starting First Time Setup"

Install-Scoop

Install-ScoopBuckets

Install-CorePackages

Install-Chocolatey

Install-Winget

$confirm = Read-Host "Install optional Python tools? (y/n)"

if ($confirm -eq "y") {

    pipInstallEssential

}

Write-Section "Setup Completed Successfully"

#endregion
