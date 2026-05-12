#Requires -Version 5.1
<#
.SYNOPSIS
    chezmoi run_once script - called automatically by "chezmoi apply".
    Installs packages from packages.json using the package managers
    that setup.ps1 already bootstrapped.

.NOTES
    This file is named run_once_after_apply.ps1 so chezmoi runs it
    exactly once (tracked by content hash). To force a re-run, change
    any character in this file, then run "chezmoi apply" again.

    It does NOT re-bootstrap Scoop/Git/Chocolatey/Winget - setup.ps1
    did that. It only installs the application packages.

    Safe to re-run manually: .\run_once_after_apply.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# ==============================================================================
# DISPLAY HELPERS
# ==============================================================================

function Write-Section {
    param([string]$Msg)
    Write-Host ""
    Write-Host "  +- $Msg " -ForegroundColor DarkCyan -NoNewline
    Write-Host ('-' * [math]::Max(2, 62 - $Msg.Length)) -ForegroundColor DarkCyan
    Write-Host ""
}

function Write-OK   { param([string]$m) Write-Host "     [OK]  $m" -ForegroundColor Green }
function Write-SKIP { param([string]$m) Write-Host "     [--]  $m" -ForegroundColor DarkYellow }
function Write-FAIL { param([string]$m) Write-Host "     [XX]  $m" -ForegroundColor Red }
function Write-INFO { param([string]$m) Write-Host "     ->  $m"   -ForegroundColor Gray }
function Write-WARN { param([string]$m) Write-Host "     [!!]  $m" -ForegroundColor Yellow }

# ==============================================================================
# UTILITIES
# ==============================================================================

function Test-Cmd {
    param([string]$n)
    return $null -ne (Get-Command $n -ErrorAction SilentlyContinue)
}

function Get-IsAdmin {
    $id = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $id.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Rebuild $env:PATH from registry + known shim paths so package manager
# commands are available even in a fresh chezmoi subprocess session.
function Update-SessionPath {
    $scoop = if ($env:SCOOP) { $env:SCOOP } else { "$env:USERPROFILE\scoop" }
    $prepend = @(
        "$scoop\shims"
        "$scoop\apps\python\current"
        "$scoop\apps\python\current\Scripts"
        "$env:ChocolateyInstall\bin"
        'C:\ProgramData\chocolatey\bin'
    )
    $machine = [Environment]::GetEnvironmentVariable('PATH', 'Machine') -split ';'
    $user    = [Environment]::GetEnvironmentVariable('PATH', 'User')    -split ';'
    $env:PATH = (($prepend + $machine + $user) |
        Where-Object { $_ -and $_.Trim() -ne '' } |
        Select-Object -Unique) -join ';'
}

# Strip trailing commas from JSON (common hand-edit mistake)
function Repair-Json {
    param([string]$Path)
    return (Get-Content $Path -Raw) -replace ',(\s*[}\]])', '$1'
}

# ==============================================================================
# LOAD packages.json
# ==============================================================================

function Get-PackageConfig {
    $p = "$env:USERPROFILE\.local\share\chezmoi\AppData\Local\installer\packages.json"
    if (-not (Test-Path $p)) {
        Write-FAIL "packages.json not found at: $p"
        Write-INFO "chezmoi init must complete before this script runs."
        return $null
    }
    try {
        $cfg = (Repair-Json -Path $p) | ConvertFrom-Json
        Write-OK "packages.json loaded."
        return $cfg
    } catch {
        Write-FAIL "Failed to parse packages.json: $_"
        return $null
    }
}

function Get-Prop {
    param($Obj, [string]$Name)
    if ($null -ne $Obj -and $Obj.PSObject.Properties[$Name]) { return $Obj.$Name }
    return @()
}

# ==============================================================================
# SCOOP PACKAGES
# ==============================================================================

function Install-ScoopPackages {
    param([array]$UserPackages = @(), [array]$GlobalPackages = @())
    Write-Section "Scoop Packages"

    if (-not (Test-Cmd 'scoop')) { Write-SKIP "Scoop not available."; return }

    # Build installed sets once (not per-package)
    $instUser   = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $instGlobal = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    scoop list 2>$null | Select-Object -Skip 1 | ForEach-Object {
        $n = if ($_ -is [string]) { ($_ -split '\s+')[0] } else { $_.Name }
        if ($n) { [void]$instUser.Add($n) }
    }
    scoop list --global 2>$null | Select-Object -Skip 1 | ForEach-Object {
        $n = if ($_ -is [string]) { ($_ -split '\s+')[0] } else { $_.Name }
        if ($n) { [void]$instGlobal.Add($n) }
    }

    # User-scope packages
    foreach ($pkg in $UserPackages) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        $short = ($pkg -split '/')[-1]
        if ($instUser.Contains($short)) { Write-SKIP $short; continue }
        Write-INFO "scoop install $pkg"
        scoop install $pkg 2>&1 | Where-Object { $_ -notmatch '^WARN.*aria2' } | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-OK $short; [void]$instUser.Add($short) }
        else                     { Write-FAIL "$short failed (will retry next apply)" }
    }

    # Global-scope packages (fonts etc  -  needs admin)
    $isAdmin = Get-IsAdmin
    foreach ($pkg in $GlobalPackages) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        $short = ($pkg -split '/')[-1]
        if ($instGlobal.Contains($short)) { Write-SKIP "$short (global)"; continue }
        if (-not $isAdmin) { Write-WARN "$short (global) needs Administrator  -  re-run elevated."; continue }
        Write-INFO "scoop install --global $pkg"
        scoop install --global $pkg 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-OK "$short (global)"; [void]$instGlobal.Add($short) }
        else                     { Write-FAIL "$short (global) failed" }
    }
}

# ==============================================================================
# WINGET PACKAGES
# ==============================================================================

function Install-WingetPackages {
    param([string[]]$Packages = @())
    Write-Section "Winget Packages"

    if (-not (Test-Cmd 'winget')) { Write-SKIP "Winget not available."; return }

    $installedRaw = winget list --accept-source-agreements 2>$null | Out-String

    foreach ($pkg in $Packages) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        if ($installedRaw -match [regex]::Escape($pkg)) { Write-SKIP $pkg; continue }
        Write-INFO "winget install $pkg"
        winget install --id $pkg --source winget `
            --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-OK $pkg }
        else                     { Write-FAIL "$pkg failed (will retry next apply)" }
    }
}

# ==============================================================================
# CHOCOLATEY PACKAGES
# ==============================================================================

function Install-ChocoPackages {
    param([string[]]$Packages = @())
    Write-Section "Chocolatey Packages"

    if (-not (Test-Cmd 'choco')) { Write-SKIP "Chocolatey not available."; return }

    $instChoco = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    choco list 2>$null | ForEach-Object {
        if ($_ -match '^(\S+)\s+\S') { [void]$instChoco.Add($matches[1]) }
    }

    $batch    = [System.Collections.Generic.List[string]]::new()
    $versioned = [System.Collections.Generic.List[hashtable]]::new()

    foreach ($pkg in $Packages) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        if ($pkg -match '^(.+?)\s+--version[= ](\S+)$') {
            $name = $matches[1].Trim(); $ver = $matches[2].Trim()
            if ($instChoco.Contains($name)) { Write-SKIP $name; continue }
            $versioned.Add(@{ Name=$name; Version=$ver })
        } else {
            if ($instChoco.Contains($pkg)) { Write-SKIP $pkg; continue }
            $batch.Add($pkg)
        }
    }

    if ($batch.Count -gt 0) {
        Write-INFO "Batch: $($batch -join ', ')"
        choco install @batch -y 2>&1 | Out-Null
        $nowInstalled = choco list 2>$null | Out-String
        foreach ($p in $batch) {
            if ($nowInstalled -match "(?m)^$([regex]::Escape($p))\s") { Write-OK $p }
            else { Write-FAIL "$p failed (will retry next apply)" }
        }
    }

    foreach ($v in $versioned) {
        Write-INFO "choco install $($v.Name) --version=$($v.Version)"
        choco install $v.Name --version=$($v.Version) -y 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-OK $v.Name }
        else                     { Write-FAIL "$($v.Name) failed" }
    }
}

# ==============================================================================
# PIP ESSENTIALS
# ==============================================================================

function Install-PipEssentials {
    Write-Section "pip Packages"

    $py = "$env:USERPROFILE\scoop\apps\python\current\python.exe"
    if (-not (Test-Path $py)) { $py = if (Test-Cmd 'python') { 'python' } else { $null } }
    if (-not $py) { Write-FAIL "Python not found."; return }

    & $py -m pip install --upgrade pip --quiet 2>$null
    foreach ($p in @('gdown')) {
        if (& $py -m pip show $p 2>$null) { Write-SKIP $p }
        else { & $py -m pip install $p --quiet; Write-OK "$p installed." }
    }
}

# ==============================================================================
# VSCODE / VSCODIUM EXTENSIONS
# ==============================================================================

function Install-VSCodeExtensions {
    Write-Section "VSCode / VSCodium Extensions"

    $extensions = @(
        'asvetliakov.vscode-neovim'
        'bungcip.better-toml'
        'devgauravjatt.github-catppuccin-dark'
        'dsznajder.es7-react-js-snippets'
        'formulahendry.code-runner'
        'github.copilot'
        'github.copilot-chat'
        'github.github-vscode-theme'
        'jdinhlife.gruvbox'
        'joshmu.periscope'
        'mhkb.vscode-theme-darcula-stormy'
        'michaelzhou.fleet-theme'
        'ms-python.debugpy'
        'ms-python.python'
        'ms-vscode.live-server'
        'ms-vscode.powershell'
        'nicohlr.pycharm'
        'robole.file-bunny'
        'sourcegraph.cody-ai'
        'tamasfe.even-better-toml'
        'zainchen.json'
    )

    $editors = @()
    $vsc  = "$env:USERPROFILE\scoop\apps\vscode\current\bin\code.cmd"
    $vscu = "$env:USERPROFILE\scoop\apps\vscodium\current\bin\codium.cmd"
    if (Test-Path $vsc)      { $editors += @{ Cmd=$vsc;  Label='VSCode'   } }
    elseif (Test-Cmd 'code') { $editors += @{ Cmd='code'; Label='VSCode'  } }
    if (Test-Path $vscu)       { $editors += @{ Cmd=$vscu;   Label='VSCodium' } }
    elseif (Test-Cmd 'codium') { $editors += @{ Cmd='codium'; Label='VSCodium' } }

    if ($editors.Count -eq 0) { Write-SKIP "No VSCode or VSCodium found."; return }

    foreach ($ed in $editors) {
        Write-INFO "Installing extensions for $($ed.Label)..."
        $cur = & $ed.Cmd --list-extensions 2>$null
        $missing = $extensions | Where-Object { $cur -notcontains $_ }
        if ($missing.Count -eq 0) { Write-SKIP "All extensions up-to-date ($($ed.Label))"; continue }
        foreach ($ext in $missing) {
            & $ed.Cmd --install-extension $ext --force 2>$null | Out-Null
            Write-OK "$ext -> $($ed.Label)"
        }
    }

    # Sync extension list back to vscode.json for chezmoi tracking
    $jsonPath = "$env:USERPROFILE\.local\share\chezmoi\AppData\Local\installer\vscode.json"
    if (Test-Path $jsonPath) {
        try {
            $json = Get-Content $jsonPath -Raw | ConvertFrom-Json
            $updated = $false
            foreach ($ed in $editors) {
                $key = if ($ed.Label -eq 'VSCodium') { 'vscodium' } else { 'vscode' }
                $current = & $ed.Cmd --list-extensions 2>$null
                if ($json.PSObject.Properties[$key] -and ($json.$key -join ',') -ne ($current -join ',')) {
                    $json.$key = $current
                    $updated = $true
                }
            }
            if ($updated) {
                $json | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8
                Write-OK "vscode.json updated."
            }
        } catch {
            Write-WARN "Could not update vscode.json: $_"
        }
    }
}

# ==============================================================================
# PACKAGE PINS
# ==============================================================================

function Set-PackagePins {
    Write-Section "Package Pins"

    if (Test-Cmd 'choco') {
        $pinned = choco pin list 2>$null | Out-String
        foreach ($p in @('zoxide')) {
            if ($pinned -match [regex]::Escape($p)) { Write-SKIP "$p pinned (choco)" }
            elseif ((choco list 2>$null | Out-String) -match "(?m)^$([regex]::Escape($p))\s") {
                choco pin add -n $p 2>$null | Out-Null; Write-OK "$p pinned (choco)"
            } else { Write-INFO "$p not installed - skipping choco pin" }
        }
    }

    if (Test-Cmd 'winget') {
        $pinnedW = winget pin list 2>$null | Out-String
        foreach ($id in @('AutoHotkey.AutoHotkey', 'Spotify.Spotify', 'OliverSchwendener.ueli')) {
            if ($pinnedW -match [regex]::Escape($id)) { Write-SKIP "$id pinned (winget)"; continue }
            $inst = (winget list --id $id --accept-source-agreements 2>$null | Out-String) -match [regex]::Escape($id)
            if (-not $inst) {
                winget install --id $id --source winget `
                    --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
            }
            winget pin add --id $id 2>$null | Out-Null
            Write-OK "$id pinned (winget)"
        }
    }
}

# ==============================================================================
# MACHINE DEFAULTS (full profile only  -  idempotent)
# ==============================================================================

function Set-MachineDefaults {
    Write-Section "Machine Defaults"
    $admin = Get-IsAdmin

    # Timezone
    if ((Get-TimeZone).Id -ne 'India Standard Time') {
        try { Set-TimeZone -Name 'India Standard Time'; Write-OK "Timezone -> IST." }
        catch { Write-FAIL "Timezone: $_" }
    } else { Write-SKIP "Timezone already IST." }

    if ($admin) {
        # Disable clipboard history service
        $cbReg = 'HKLM:\SYSTEM\CurrentControlSet\Services\cbdhsvc'
        if (Test-Path $cbReg) {
            if ((Get-ItemProperty $cbReg 'Start' -EA SilentlyContinue).Start -ne 4) {
                try { Set-ItemProperty $cbReg 'Start' 4 -Force; Write-OK "Clipboard service disabled." }
                catch { Write-FAIL "Clipboard reg: $_" }
            } else { Write-SKIP "Clipboard service already disabled." }
        }

        # Disable clipboard history policy
        $polReg = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
        if (-not (Test-Path $polReg)) { New-Item $polReg -Force | Out-Null }
        if ((Get-ItemProperty $polReg 'AllowClipboardHistory' -EA SilentlyContinue).AllowClipboardHistory -ne 0) {
            Set-ItemProperty $polReg 'AllowClipboardHistory' 0 -Type DWord
            Write-OK "Clipboard history policy disabled."
        } else { Write-SKIP "Clipboard history already disabled." }

        # WSL2
        if ((wsl --status 2>&1 | Out-String) -match 'Default Version') {
            Write-SKIP "WSL already installed."
        } else {
            dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart 2>&1 | Out-Null
            dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart 2>&1 | Out-Null
            wsl --set-default-version 2 2>&1 | Out-Null
            Write-OK "WSL2 enabled (reboot required)."
        }

        # Clink PATH
        $clinkDir = 'C:\Program Files (x86)\clink'
        if ((Test-Path $clinkDir) -and ($env:PATH -notlike "*$clinkDir*")) {
            $mp = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
            [Environment]::SetEnvironmentVariable('PATH', "$mp;$clinkDir", 'Machine')
            Write-OK "Clink added to system PATH."
        } elseif (Test-Path $clinkDir) { Write-SKIP "Clink already in PATH." }

        # ADB PATH
        $adbDir = "$env:USERPROFILE\AppData\Local\installer\adbdrivers"
        if ((Test-Path $adbDir) -and ($env:PATH -notlike "*$adbDir*")) {
            $mp = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
            [Environment]::SetEnvironmentVariable('PATH', "$mp;$adbDir", 'Machine')
            Write-OK "ADB path added to system PATH."
        } elseif (Test-Path $adbDir) { Write-SKIP "ADB path already in PATH." }
    } else {
        Write-INFO "Skipping admin-only steps (clipboard, WSL, Clink, ADB paths)."
    }

    # MSI Afterburner + RTSS startup shortcuts
    $startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    @(
        @{ Exe="$env:USERPROFILE\scoop\apps\msiafterburner\current\msiafterburner.exe"; Name='MSIAfterburner' }
        @{ Exe="$env:USERPROFILE\scoop\apps\rtss\current\RTSS.exe";                     Name='RTSS' }
    ) | ForEach-Object {
        if (Test-Path $_.Exe) {
            $lnk = Join-Path $startupDir "$($_.Name).lnk"
            if (-not (Test-Path $lnk)) {
                $ws = New-Object -ComObject WScript.Shell
                $sc = $ws.CreateShortcut($lnk); $sc.TargetPath = $_.Exe; $sc.Save()
                Write-OK "$($_.Name) added to startup."
            } else { Write-SKIP "$($_.Name) already in startup." }
        }
    }

    # ES Config copy (C:\es)
    $esSource = "$env:USERPROFILE\.config\es"
    $esDest   = 'C:\es'
    if (Test-Path $esSource) {
        if (-not (Test-Path $esDest)) { New-Item $esDest -ItemType Directory -Force | Out-Null }
        Copy-Item "$esSource\*" $esDest -Force -ErrorAction SilentlyContinue
        Write-OK "ES config synced to C:\es."
    }

    # VSCodium product.json
    $prodSrc  = "$env:USERPROFILE\.local\share\chezmoi\AppData\Local\installer\vscodium\product.json"
    $prodDest = 'C:\Program Files\VSCodium\resources\app\product.json'
    if ((Test-Path $prodSrc) -and (Test-Path (Split-Path $prodDest))) {
        Copy-Item $prodSrc $prodDest -Force -ErrorAction SilentlyContinue
        Write-OK "VSCodium product.json updated."
    }

    # Spotify via SpotX
    $spotExe = "$env:APPDATA\Spotify\spotify.exe"
    if (-not (Test-Path $spotExe)) {
        Write-INFO "Installing Spotify via SpotX..."
        Set-MpPreference -DisableRealtimeMonitoring $true -EA SilentlyContinue
        $spotScript = "$env:TEMP\spotx-run.ps1"
        Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1' -OutFile $spotScript
        powershell -ExecutionPolicy Bypass -File $spotScript -new_theme
        Remove-Item $spotScript -Force -EA SilentlyContinue
        Set-MpPreference -DisableRealtimeMonitoring $false -EA SilentlyContinue
        Write-OK "Spotify installed."
    } else { Write-SKIP "Spotify already installed." }
}

# ==============================================================================
# MAIN
# ==============================================================================

Write-Host ""
Write-Host "+======================================================================+" -ForegroundColor DarkCyan
Write-Host "|          chezmoi run_once -- post-apply package install              |" -ForegroundColor Cyan
Write-Host "+======================================================================+" -ForegroundColor DarkCyan
Write-Host ""

Update-SessionPath

$config = Get-PackageConfig
if (-not $config) {
    Write-FAIL "Cannot install packages without packages.json. Exiting."
    exit 0   # exit 0 so chezmoi does not mark the apply as failed
}

# Ask for profile
$choice = ''
while ($choice -notin @('mini','m','full','f')) {
    $choice = (Read-Host "     Install profile  [mini / full]").Trim().ToLower()
    if ($choice -notin @('mini','m','full','f')) { Write-Host "     Type 'mini' or 'full'." -ForegroundColor Red }
}
$isFull = $choice -in @('full','f')

$scoopPkgs  = if ($isFull) { Get-Prop $config.scoop  'full'   } else { Get-Prop $config.scoop  'mini'   }
$scoopGlob  = Get-Prop $config.scoop 'global'
$wingetPkgs = if ($isFull) { Get-Prop $config.winget 'full'   } else { Get-Prop $config.winget 'mini'   }
$chocoPkgs  = if ($isFull) { Get-Prop $config.choco  'full'   } else { Get-Prop $config.choco  'mini'   }

Install-ScoopPackages  -UserPackages $scoopPkgs -GlobalPackages $scoopGlob
Install-WingetPackages -Packages $wingetPkgs
Install-ChocoPackages  -Packages $chocoPkgs

if ($isFull) { Install-PipEssentials }

Install-VSCodeExtensions
Set-PackagePins

if ($isFull) { Set-MachineDefaults }

Write-Host ""
Write-Host "+======================================================================+" -ForegroundColor DarkCyan
Write-Host "|                    run_once complete                                 |" -ForegroundColor Cyan
Write-Host "+======================================================================+" -ForegroundColor DarkCyan
Write-Host ""
