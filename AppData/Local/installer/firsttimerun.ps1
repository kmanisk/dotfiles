<#
.SYNOPSIS
    Complete first-time Windows bootstrap script
    Installs Scoop, Python, Winget, Chocolatey
    Fixes PATH priority and removes WindowsApps python alias conflict
    Fully automated, no Microsoft Store dependency
#>

#region Utility

function Write-Section($msg) {
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor DarkGray
    Write-Host $msg -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor DarkGray
    Write-Host ""
}

function Is-Admin {
    $identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

#endregion


#region Scoop Install

function Install-Scoop {

    Write-Section "Installing Scoop"

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {

        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

        Write-Host "Scoop installed." -ForegroundColor Green
    }
    else {
        Write-Host "Scoop already installed." -ForegroundColor Yellow
    }

    # Ensure SCOOP env variable exists
    if (-not $env:SCOOP) {

        $env:SCOOP = "$env:USERPROFILE\scoop"

        [Environment]::SetEnvironmentVariable(
            "SCOOP",
            $env:SCOOP,
            "User"
        )
    }

}

#endregion


#region Scoop Python Install

function Install-ScoopPython {

    Write-Section "Installing Python via Scoop"

    scoop bucket add main 2>$null

    scoop install python 2>$null

    $pythonPath = "$env:USERPROFILE\scoop\apps\python\current"

    if (Test-Path "$pythonPath\python.exe") {

        Write-Host "Python installed at: $pythonPath" -ForegroundColor Green
    }
    else {

        Write-Host "Python install failed." -ForegroundColor Red
        exit 1
    }

}

#endregion


#region Fix Python PATH Priority

function Fix-PythonPathPriority {

    Write-Section "Fixing Python PATH priority"

    $scoopPython = "$env:USERPROFILE\scoop\apps\python\current"
    $windowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    $pathParts = $userPath -split ';' | Where-Object {
        $_ -and ($_ -ne $windowsApps) -and ($_ -ne $scoopPython)
    }

    $newPathParts = @($scoopPython) + $pathParts

    $newPath = $newPathParts -join ';'

    [Environment]::SetEnvironmentVariable(
        "PATH",
        $newPath,
        "User"
    )

    # Refresh current session
    $env:PATH = $newPath + ";" + [Environment]::GetEnvironmentVariable("PATH", "Machine")

    # Disable WindowsApps python alias completely
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\python.exe `
        /f `
        /ve `
        /d "$scoopPython\python.exe" | Out-Null

    # Clear cache
    Remove-Item Alias:\python -ErrorAction SilentlyContinue
    Remove-Item Function:\python -ErrorAction SilentlyContinue

    $resolved = where.exe python 2>$null

    if ($resolved -and $resolved[0] -like "*scoop*") {

        Write-Host "Python priority fixed." -ForegroundColor Green
        Write-Host "Active python: $($resolved[0])"
    }
    else {

        Write-Host "Python priority fixed for new terminals." -ForegroundColor Yellow
        Write-Host "Restart terminal after script completes."
    }

}

#endregion


#region Winget Install

function Install-Winget {

    Write-Section "Checking Winget"

    if (Get-Command winget -ErrorAction SilentlyContinue) {

        Write-Host "Winget already installed." -ForegroundColor Green
        return
    }

    Write-Host "Installing Winget..."

    scoop bucket add extras 2>$null
    scoop install extras/winget

}

#endregion


#region Chocolatey Install

function Install-Chocolatey {

    Write-Section "Checking Chocolatey"

    if (Get-Command choco -ErrorAction SilentlyContinue) {

        Write-Host "Chocolatey already installed." -ForegroundColor Green
        return
    }

    Write-Host "Installing Chocolatey..."

    Set-ExecutionPolicy Bypass -Scope Process -Force

    Invoke-Expression (
        (New-Object Net.WebClient).DownloadString(
            'https://chocolatey.org/install.ps1'
        )
    )

}

#endregion


#region Install Core Tools

function Install-CoreTools {

    Write-Section "Installing core tools"

    scoop install git 2>$null
    scoop install gh 2>$null
    scoop install chezmoi 2>$null
    scoop install aria2 2>$null

}

#endregion


#region Verify Python

function Verify-Python {

    Write-Section "Verifying Python"

    $pythonExe = "$env:USERPROFILE\scoop\apps\python\current\python.exe"

    if (-not (Test-Path $pythonExe)) {

        Write-Host "Python missing." -ForegroundColor Red
        exit 1
    }

    & $pythonExe --version

}

#endregion


#region Main

Write-Section "Starting Windows Bootstrap"

Install-Scoop

Install-ScoopPython

Fix-PythonPathPriority

Install-Winget

Install-Chocolatey

Install-CoreTools

Verify-Python

Write-Section "Bootstrap Completed Successfully"

#endregion
