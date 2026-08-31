#Requires -Version 5.1
<#
.SYNOPSIS
    chezmoi run_once script - post-apply package installer with declarative management.

.NOTES
    Declarative mode (NixOS-style):
      - Packages added to packages.json   -> installed automatically on next chezmoi apply
      - Packages removed from packages.json -> uninstalled automatically on next chezmoi apply
      - Packages installed manually by user -> NEVER touched (only manages what IT installed)
      - A manifest tracks which packages this script installed previously

    Profile choice is read from %TEMP%\dotfiles-profile-choice.txt (written by setup.ps1).
    If missing (manual chezmoi apply), prompts once and saves the answer.

    Manifest: %USERPROFILE%\.local\share\chezmoi\AppData\Local\installer\managed-pkgs.json
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# ==============================================================================
# DISPLAY
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

function Test-Cmd { param([string]$n) return $null -ne (Get-Command $n -ErrorAction SilentlyContinue) }

function Get-IsAdmin {
    $id = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $id.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Update-SessionPath {
    $scoop = if ($env:SCOOP) { $env:SCOOP } else { "$env:USERPROFILE\scoop" }
    $prepend = @(
        "$scoop\shims"
        "$scoop\apps\python\current"
        "$scoop\apps\python\current\Scripts"
        "$env:ChocolateyInstall\bin"
        'C:\ProgramData\chocolatey\bin'
        "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    )
    $machine = [Environment]::GetEnvironmentVariable('PATH', 'Machine') -split ';'
    $user    = [Environment]::GetEnvironmentVariable('PATH', 'User')    -split ';'
    $env:PATH = (($prepend + $machine + $user) |
        Where-Object { $_ -and $_.Trim() -ne '' } | Select-Object -Unique) -join ';'
}

function Repair-Json {
    param([string]$Path)
    return (Get-Content $Path -Raw) -replace ',(\s*[}\]])', '$1'
}

function Get-Prop {
    param($Obj, [string]$Name)
    if ($null -ne $Obj -and $Obj.PSObject.Properties[$Name]) { return @($Obj.$Name) }
    return @()
}

# Strip bucket prefix: "extras/ditto" -> "ditto"
function Get-ShortName { param([string]$pkg) return ($pkg -split '/')[-1].ToLower() }

# ==============================================================================
# DECLARATIVE MANIFEST
# Tracks exactly which packages this script installed. Only these are candidates
# for auto-uninstall. Packages the user installed manually are never touched.
# ==============================================================================

$MANIFEST_PATH = "$env:USERPROFILE\.local\share\chezmoi\AppData\Local\installer\managed-pkgs.json"

function Get-Manifest {
    if (Test-Path $MANIFEST_PATH) {
        try { return (Get-Content $MANIFEST_PATH -Raw | ConvertFrom-Json) }
        catch { }
    }
    return [PSCustomObject]@{ scoop_user=@(); scoop_global=@(); winget=@(); choco=@() }
}

function Save-Manifest { param($Manifest)
    try {
        $dir = Split-Path $MANIFEST_PATH
        if (-not (Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
        $Manifest | ConvertTo-Json -Depth 5 | Set-Content $MANIFEST_PATH -Encoding UTF8
    } catch { Write-WARN "Could not save manifest: $_" }
}

# ==============================================================================
# LOAD packages.json
# ==============================================================================

function Get-PackageConfig {
    $p = "$env:USERPROFILE\.local\share\chezmoi\AppData\Local\installer\packages.json"
    if (-not (Test-Path $p)) { Write-FAIL "packages.json not found at: $p"; return $null }
    try {
        $cfg = ((Get-Content $p -Raw) -replace ',(\s*[}\]])', '$1') | ConvertFrom-Json
        Write-OK "packages.json loaded."
        return $cfg
    } catch { Write-FAIL "Failed to parse packages.json: $_"; return $null }
}

# ==============================================================================
# SCOOP - declarative install / update / uninstall
# ==============================================================================

function Invoke-ScoopPackages {
    param([array]$Desired = @(), [array]$DesiredGlobal = @())
    Write-Section "Scoop Packages"
    if (-not (Test-Cmd 'scoop')) { Write-SKIP "Scoop not available."; return }

    $manifest = Get-Manifest

    # Build installed sets -- handles both PS5.1 (strings) and PS7 (objects)
    $instUser   = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $instGlobal = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    @(scoop list 2>$null) | ForEach-Object {
        $n = if ($_ -is [string]) { ($_ -split '\s+')[0] } elseif ($_.Name) { $_.Name } else { $null }
        if ($n -and $n -match '\S' -and $n -notmatch '^(Name|---)') { [void]$instUser.Add($n) }
    }
    @(scoop list --global 2>$null) | ForEach-Object {
        $n = if ($_ -is [string]) { ($_ -split '\s+')[0] } elseif ($_.Name) { $_.Name } else { $null }
        if ($n -and $n -match '\S' -and $n -notmatch '^(Name|---)') { [void]$instGlobal.Add($n) }
    }

    # Desired short names set (for uninstall comparison)
    $desiredShorts = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($pkg in $Desired) { [void]$desiredShorts.Add((Get-ShortName $pkg)) }

    # Declarative uninstall: was in manifest, not in desired, and is installed
    foreach ($prev in @($manifest.scoop_user)) {
        if (-not $desiredShorts.Contains($prev) -and $instUser.Contains($prev)) {
            Write-INFO "Removing $prev (no longer in packages.json)..."
            scoop uninstall $prev 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-OK "$prev uninstalled."; [void]$instUser.Remove($prev) }
            else { Write-WARN "$prev uninstall failed - remove manually with: scoop uninstall $prev" }
        }
    }

    # Split desired into: need install vs need update-check
    # Note: Git installs 7zip as a dependency so 7zip lands in $instUser already.
    # Treating it as update-check is correct - it will just show (up to date).
    $toInstall = [System.Collections.Generic.List[string]]::new()
    $toUpdate  = [System.Collections.Generic.List[string]]::new()

    foreach ($pkg in $Desired) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        $short = Get-ShortName $pkg
        if ($instUser.Contains($short)) { [void]$toUpdate.Add($short) }
        else                            { $toInstall.Add($pkg) }
    }

    if ($toInstall.Count -gt 0) {
        Write-INFO "Installing $($toInstall.Count) new package(s)..."
        foreach ($pkg in $toInstall) {
            $short = Get-ShortName $pkg
            Write-INFO "scoop install $pkg"
            $out = @(scoop install $pkg 2>&1)
            $out | Where-Object { $_ -notmatch '^WARN.*aria2' } | ForEach-Object { Write-INFO "  $_" }
            Update-SessionPath
            # Check existence rather than $LASTEXITCODE (pipe can clobber it)
            $nowInstalled = $false
            @(scoop list 2>$null) | ForEach-Object {
                $n = if ($_ -is [string]) { ($_ -split '\s+')[0] } elseif ($_.Name) { $_.Name } else { $null }
                if ($n -ieq $short) { $nowInstalled = $true }
            }
            if ($nowInstalled) { Write-OK "$short installed."; [void]$instUser.Add($short) }
            else               { Write-FAIL "$short install failed." }
        }
    }

    if ($toUpdate.Count -gt 0) {
        Write-INFO "Checking $($toUpdate.Count) installed package(s) for updates..."
        foreach ($short in $toUpdate) {
            Write-INFO "scoop update $short"
            # Collect as array then join to capture both stdout and stderr on PS5.1
            $outLines = @(scoop update $short 2>&1)
            $outStr   = $outLines -join "`n"
            if ($outStr -match 'latest version|already up to date|Latest versions for all apps') {
                Write-SKIP "$short (up to date)"
            } elseif ($outStr -match 'ERROR|FAIL') {
                Write-WARN "$short update had errors."
            } else {
                Write-OK "$short updated."
            }
        }
    }

    # Global packages (fonts, system tools - need admin)
    $desiredGlobalShorts = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($pkg in $DesiredGlobal) { [void]$desiredGlobalShorts.Add((Get-ShortName $pkg)) }

    $isAdmin = Get-IsAdmin

    # Declarative uninstall global
    foreach ($prev in @($manifest.scoop_global)) {
        if (-not $desiredGlobalShorts.Contains($prev) -and $instGlobal.Contains($prev)) {
            if (-not $isAdmin) { Write-WARN "$prev (global) needs uninstall but not admin - re-run elevated."; continue }
            Write-INFO "Removing $prev --global (no longer in packages.json)..."
            scoop uninstall $prev --global 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-OK "$prev (global) uninstalled."; [void]$instGlobal.Remove($prev) }
            else { Write-WARN "$prev (global) uninstall failed." }
        }
    }

    foreach ($pkg in $DesiredGlobal) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        $short = Get-ShortName $pkg
        if (-not $isAdmin) { Write-WARN "$short (global) needs admin - re-run elevated."; continue }

        if ($instGlobal.Contains($short)) {
            # Update check
            $outLines = @(scoop update $short --global 2>&1)
            $outStr   = $outLines -join "`n"
            if ($outStr -match 'latest version|already up to date|Latest versions for all apps') {
                Write-SKIP "$short (global, up to date)"
            } elseif ($outStr -match 'ERROR|FAIL') {
                Write-WARN "$short (global) update had errors."
            } else {
                Write-OK "$short (global) updated."
            }
        } else {
            Write-INFO "scoop install --global $pkg"
            $out = @(scoop install --global $pkg 2>&1)
            $out | Where-Object { $_ -notmatch '^WARN.*aria2' } | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-OK "$short (global) installed."; [void]$instGlobal.Add($short) }
            else { Write-FAIL "$short (global) install failed." }
        }
    }

    # Save manifest with current desired state
    $manifest.scoop_user   = @($Desired      | ForEach-Object { Get-ShortName $_ })
    $manifest.scoop_global = @($DesiredGlobal | ForEach-Object { Get-ShortName $_ })
    Save-Manifest $manifest
    Update-SessionPath
}

# ==============================================================================
# WINGET - declarative
# ==============================================================================

function Invoke-WingetPackages {
    param([string[]]$Desired = @())
    Write-Section "Winget Packages"
    if (-not (Test-Cmd 'winget')) { Write-SKIP "Winget not available."; return }

    $manifest     = Get-Manifest
    $installedRaw = winget list --accept-source-agreements 2>$null | Out-String

    # Declarative uninstall
    foreach ($prev in @($manifest.winget)) {
        if ($Desired -notcontains $prev -and $installedRaw -match [regex]::Escape($prev)) {
            Write-INFO "Removing $prev (no longer in packages.json)..."
            winget uninstall --id $prev --silent 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-OK "$prev uninstalled." }
            else { Write-WARN "$prev uninstall failed - remove manually." }
        }
    }

    foreach ($pkg in $Desired) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        if ($installedRaw -match [regex]::Escape($pkg)) { Write-SKIP $pkg; continue }
        Write-INFO "winget install $pkg"
        winget install --id $pkg --source winget `
            --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-OK "$pkg installed." }
        else { Write-FAIL "$pkg failed." }
    }

    $manifest.winget = @($Desired)
    Save-Manifest $manifest
}

# ==============================================================================
# PIP
# ==============================================================================

function Invoke-PipEssentials {
    Write-Section "pip Packages"
    $py = "$env:USERPROFILE\scoop\apps\python\current\python.exe"
    if (-not (Test-Path $py)) {
        # Reject the Windows Store execution-alias stub -- it resolves via
        # Get-Command but isn't a real interpreter, and silently no-ops pip.
        $cmd = Get-Command 'python' -EA SilentlyContinue
        if ($cmd -and $cmd.Source -notmatch 'WindowsApps') { $py = $cmd.Source } else { $py = $null }
    }
    if (-not $py) { Write-FAIL "Python not found (scoop install python failed earlier) - skipping pip."; return }
    & $py -m pip install --upgrade pip --quiet 2>$null
    foreach ($p in @('gdown')) {
        $shown = & $py -m pip show $p 2>$null
        if ($LASTEXITCODE -eq 0 -and $shown) { Write-SKIP $p; continue }
        & $py -m pip install $p --quiet
        if ($LASTEXITCODE -eq 0) { Write-OK "$p installed." } else { Write-FAIL "$p install failed." }
    }
}

# ==============================================================================
# VSCODE / VSCODIUM EXTENSIONS
# ==============================================================================

function Invoke-VSCodeExtensions {
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
    if (Test-Path $vsc)        { $editors += @{ Cmd=$vsc;    Label='VSCode'   } }
    elseif (Test-Cmd 'code')   { $editors += @{ Cmd='code';  Label='VSCode'   } }
    if (Test-Path $vscu)        { $editors += @{ Cmd=$vscu;   Label='VSCodium' } }
    elseif (Test-Cmd 'codium') { $editors += @{ Cmd='codium'; Label='VSCodium' } }

    if ($editors.Count -eq 0) { Write-SKIP "No VSCode or VSCodium found."; return }
    foreach ($ed in $editors) {
        Write-INFO "Extensions for $($ed.Label)..."
        $cur     = @(& $ed.Cmd --list-extensions 2>$null)
        $missing = $extensions | Where-Object { $cur -notcontains $_ }
        if ($missing.Count -eq 0) { Write-SKIP "All up-to-date ($($ed.Label))"; continue }
        foreach ($ext in $missing) {
            & $ed.Cmd --install-extension $ext --force 2>$null | Out-Null
            Write-OK "$ext -> $($ed.Label)"
        }
    }
}

# ==============================================================================
# PACKAGE PINS
# ==============================================================================

function Invoke-PackagePins {
    Write-Section "Package Pins"
    if (Test-Cmd 'winget') {
        $pinnedW = winget pin list 2>$null | Out-String
        foreach ($id in @('AutoHotkey.AutoHotkey','Spotify.Spotify','OliverSchwendener.ueli')) {
            if ($pinnedW -match [regex]::Escape($id)) { Write-SKIP "$id (winget, pinned)"; continue }
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
# MACHINE DEFAULTS
# ==============================================================================

function Invoke-MachineDefaults {
    Write-Section "Machine Defaults"
    $admin = Get-IsAdmin

    if ((Get-TimeZone).Id -ne 'India Standard Time') {
        try { Set-TimeZone -Name 'India Standard Time'; Write-OK "Timezone -> IST." }
        catch { Write-FAIL "Timezone: $_" }
    } else { Write-SKIP "Timezone already IST." }

    if ($admin) {
        $cbReg = 'HKLM:\SYSTEM\CurrentControlSet\Services\cbdhsvc'
        if (Test-Path $cbReg) {
            $cur = (Get-ItemProperty $cbReg 'Start' -EA SilentlyContinue).Start
            if ($cur -ne 4) {
                try { Set-ItemProperty $cbReg 'Start' 4 -Force; Write-OK "Clipboard service disabled." }
                catch { Write-FAIL "Clipboard: $_" }
            } else { Write-SKIP "Clipboard service already disabled." }
        }
        $polReg = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
        if (-not (Test-Path $polReg)) { New-Item $polReg -Force | Out-Null }
        $chProp = Get-ItemProperty -Path $polReg -Name 'AllowClipboardHistory' -EA SilentlyContinue
        $chVal  = if ($chProp -and $chProp.PSObject.Properties['AllowClipboardHistory']) { $chProp.AllowClipboardHistory } else { $null }
        if ($chVal -ne 0) {
            Set-ItemProperty $polReg 'AllowClipboardHistory' 0 -Type DWord; Write-OK "Clipboard history disabled."
        } else { Write-SKIP "Clipboard history already disabled." }

        $wslOut = wsl --status 2>&1 | Out-String
        if ($wslOut -match 'Default Version') { Write-SKIP "WSL already installed." }
        else {
            dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart 2>&1 | Out-Null
            dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart 2>&1 | Out-Null
            wsl --set-default-version 2 2>&1 | Out-Null
            Write-OK "WSL2 enabled (reboot required)."
        }

        foreach ($dir in @('C:\Program Files (x86)\clink', "$env:USERPROFILE\AppData\Local\installer\adbdrivers")) {
            if ((Test-Path $dir) -and ($env:PATH -notlike "*$dir*")) {
                $mp = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
                [Environment]::SetEnvironmentVariable('PATH', "$mp;$dir", 'Machine')
                Write-OK "Added to system PATH: $dir"
            }
        }
    } else { Write-INFO "Skipping admin-only steps (clipboard, WSL, PATH)." }

    $startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    @(
        @{ Exe="$env:USERPROFILE\scoop\apps\msiafterburner\current\msiafterburner.exe"; Name='MSIAfterburner' }
        @{ Exe="$env:USERPROFILE\scoop\apps\rtss\current\RTSS.exe"; Name='RTSS' }
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

    $esSource = "$env:USERPROFILE\.config\es"
    if (Test-Path $esSource) {
        if (-not (Test-Path 'C:\es')) { New-Item 'C:\es' -ItemType Directory -Force | Out-Null }
        Copy-Item "$esSource\*" 'C:\es' -Force -EA SilentlyContinue
        Write-OK "ES config synced to C:\es."
    }

    $prodSrc  = "$env:USERPROFILE\.local\share\chezmoi\AppData\Local\installer\vscodium\product.json"
    $prodDest = 'C:\Program Files\VSCodium\resources\app\product.json'
    if ((Test-Path $prodSrc) -and (Test-Path (Split-Path $prodDest))) {
        Copy-Item $prodSrc $prodDest -Force -EA SilentlyContinue
        Write-OK "VSCodium product.json updated."
    }

    $spotExe = "$env:APPDATA\Spotify\spotify.exe"
    if (-not (Test-Path $spotExe)) {
        Write-INFO "Installing Spotify via SpotX..."
        $hasDefender = Test-Cmd 'Set-MpPreference'
        if ($hasDefender) { Set-MpPreference -DisableRealtimeMonitoring $true -EA SilentlyContinue }
        $s = "$env:TEMP\spotx-run.ps1"
        Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1' -OutFile $s
        # Sanitize LIB/INCLUDE so a stale toolchain path doesn't crash SpotX's binary scanner
        foreach ($envVar in 'LIB','INCLUDE') {
            $cur = [Environment]::GetEnvironmentVariable($envVar)
            if ($cur) {
                $clean = ($cur -split ';' | Where-Object { $_ -and (Test-Path $_) }) -join ';'
                [Environment]::SetEnvironmentVariable($envVar, $clean)
            }
        }
        powershell -ExecutionPolicy Bypass -File $s -new_theme
        Remove-Item $s -Force -EA SilentlyContinue
        if ($hasDefender) { Set-MpPreference -DisableRealtimeMonitoring $false -EA SilentlyContinue }
        Write-OK "Spotify installed."
    } else { Write-SKIP "Spotify already installed." }
}

# ==============================================================================
# FONTS (Declarative Single TTF Downloads via curl)
# ==============================================================================

function Invoke-Fonts {
    param([array]$Desired = @())
    Write-Section "Coding Fonts (Single TTF)"
    if (-not $Desired -or $Desired.Count -eq 0) { Write-SKIP "No fonts declared in packages.json."; return }

    $fontsDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    if (-not (Test-Path $fontsDir)) {
        New-Item -ItemType Directory -Path $fontsDir -Force | Out-Null
    }
    $regPath = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }

    # Known custom direct-download registries
    $customFonts = @{
        'monocraft' = @(
            @{ Filename = 'Monocraft.ttf'; Url = 'https://github.com/IdreesInc/Monocraft/releases/download/v3.0/Monocraft.ttf'; RegName = 'Monocraft (TrueType)' }
        )
        'comicmono' = @(
            @{ Filename = 'ComicMono.ttf'; Url = 'https://raw.githubusercontent.com/dtinth/comic-mono-font/master/ComicMono.ttf'; RegName = 'Comic Mono (TrueType)' }
        )
        'pixelcode' = @(
            @{ Filename = 'PixelCode.ttf'; ZipUrl = 'https://github.com/qwerasd205/PixelCode/releases/latest/download/ttf.zip'; ZipInnerPath = 'ttf/PixelCode.ttf'; RegName = 'Pixel Code (TrueType)' }
        )
        'aporeticsansmono' = @(
            @{ Filename = 'aporetic-sans-mono-normalregularupright.ttf'; Url = 'https://raw.githubusercontent.com/protesilaos/aporetic/main/aporetic-sans-mono/TTF/aporetic-sans-mono-normalregularupright.ttf'; RegName = 'Aporetic Sans Mono (TrueType)' },
            @{ Filename = 'aporetic-sans-mono-normalboldupright.ttf';    Url = 'https://raw.githubusercontent.com/protesilaos/aporetic/main/aporetic-sans-mono/TTF/aporetic-sans-mono-normalboldupright.ttf';    RegName = 'Aporetic Sans Mono Bold (TrueType)' },
            @{ Filename = 'aporetic-sans-mono-normalregularitalic.ttf';  Url = 'https://raw.githubusercontent.com/protesilaos/aporetic/main/aporetic-sans-mono/TTF/aporetic-sans-mono-normalregularitalic.ttf';  RegName = 'Aporetic Sans Mono Italic (TrueType)' },
            @{ Filename = 'aporetic-sans-mono-normalbolditalic.ttf';     Url = 'https://raw.githubusercontent.com/protesilaos/aporetic/main/aporetic-sans-mono/TTF/aporetic-sans-mono-normalbolditalic.ttf';     RegName = 'Aporetic Sans Mono Bold Italic (TrueType)' }
        )
        'aporeticserifmono' = @(
            @{ Filename = 'aporetic-serif-mono-normalregularupright.ttf'; Url = 'https://raw.githubusercontent.com/protesilaos/aporetic/main/aporetic-serif-mono/TTF/aporetic-serif-mono-normalregularupright.ttf'; RegName = 'Aporetic Serif Mono (TrueType)' },
            @{ Filename = 'aporetic-serif-mono-normalboldupright.ttf';    Url = 'https://raw.githubusercontent.com/protesilaos/aporetic/main/aporetic-serif-mono/TTF/aporetic-serif-mono-normalboldupright.ttf';    RegName = 'Aporetic Serif Mono Bold (TrueType)' },
            @{ Filename = 'aporetic-serif-mono-normalregularitalic.ttf';  Url = 'https://raw.githubusercontent.com/protesilaos/aporetic/main/aporetic-serif-mono/TTF/aporetic-serif-mono-normalregularitalic.ttf';  RegName = 'Aporetic Serif Mono Italic (TrueType)' },
            @{ Filename = 'aporetic-serif-mono-normalbolditalic.ttf';     Url = 'https://raw.githubusercontent.com/protesilaos/aporetic/main/aporetic-serif-mono/TTF/aporetic-serif-mono-normalbolditalic.ttf';     RegName = 'Aporetic Serif Mono Bold Italic (TrueType)' }
        )
        'psudofontligamono' = @(
            @{ Filename = 'psudoFont_Liga_Mono_-_Regular.ttf';    Url = 'https://raw.githubusercontent.com/psudo-dev/psudofont-liga-mono/main/psudoFont%20Liga%20Mono/psudoFont_Liga_Mono_-_Regular.ttf';    RegName = 'psudoFont Liga Mono (TrueType)' },
            @{ Filename = 'psudoFont_Liga_Mono_-_Bold.ttf';       Url = 'https://raw.githubusercontent.com/psudo-dev/psudofont-liga-mono/main/psudoFont%20Liga%20Mono/psudoFont_Liga_Mono_-_Bold.ttf';       RegName = 'psudoFont Liga Mono Bold (TrueType)' },
            @{ Filename = 'psudoFont_Liga_Mono_-_Italic.ttf';     Url = 'https://raw.githubusercontent.com/psudo-dev/psudofont-liga-mono/main/psudoFont%20Liga%20Mono/psudoFont_Liga_Mono_-_Italic.ttf';     RegName = 'psudoFont Liga Mono Italic (TrueType)' },
            @{ Filename = 'psudoFont_Liga_Mono_-_BoldItalic.ttf'; Url = 'https://raw.githubusercontent.com/psudo-dev/psudofont-liga-mono/main/psudoFont%20Liga%20Mono/psudoFont_Liga_Mono_-_BoldItalic.ttf'; RegName = 'psudoFont Liga Mono Bold Italic (TrueType)' }
        )
    }

    # Aliases to canonical font names
    $aliases = @{
        'monoone'              = 'IntelOneMono'
        'mono-one'             = 'IntelOneMono'
        'mono one'             = 'IntelOneMono'
        'intel-one-mono'       = 'IntelOneMono'
        'intelonemono'         = 'IntelOneMono'
        'intel one mono'       = 'IntelOneMono'
        'jetbrains-mono'       = 'JetBrainsMono'
        'jetbrains'            = 'JetBrainsMono'
        'fira-code'            = 'FiraCode'
        'fira'                 = 'FiraCode'
        'cascadia-code'        = 'CascadiaCode'
        'cascadia'             = 'CascadiaCode'
        'geist-mono'           = 'GeistMono'
        'geist'                = 'GeistMono'
        'victor-mono'          = 'VictorMono'
        'fantasque'            = 'FantasqueSansMono'
        'fantasque-sans'       = 'FantasqueSansMono'
        'daddytime'            = 'DaddyTimeMono'
        'daddy-time'           = 'DaddyTimeMono'
        'gohu'                 = 'Gohu'
        'gohufont'             = 'Gohu'
        'aporetic'             = 'AporeticSansMono'
        'aporetic-sans'        = 'AporeticSansMono'
        'aporeticsans'         = 'AporeticSansMono'
        'aporetic-sans-mono'   = 'AporeticSansMono'
        'aporetic-serif'       = 'AporeticSerifMono'
        'aporeticserif'        = 'AporeticSerifMono'
        'aporetic-serif-mono'  = 'AporeticSerifMono'
        'psudo'                = 'PsudoFontLigaMono'
        'psudofont'            = 'PsudoFontLigaMono'
        'psudo-font'           = 'PsudoFontLigaMono'
        'psudofont-liga-mono'  = 'PsudoFontLigaMono'
        'psudofontligamono'    = 'PsudoFontLigaMono'
    }

    foreach ($font in $Desired) {
        if ([string]::IsNullOrWhiteSpace($font)) { continue }
        $key = $font.Trim().ToLower()
        $cleanFont = if ($aliases.ContainsKey($key)) { $aliases[$key] } else { $font.Trim() }
        $lookupKey = $cleanFont.ToLower()

        # Check if font files already exist in user fonts directory
        $prefix = if ($cleanFont -ieq 'IntelOneMono') { 'IntoneMono' }
                  elseif ($cleanFont -ieq 'Hermit') { 'Hurmit' }
                  elseif ($cleanFont -ieq 'FantasqueSansMono') { 'Fantasque' }
                  elseif ($cleanFont -ieq 'DaddyTimeMono') { 'DaddyTime' }
                  elseif ($cleanFont -ieq 'AporeticSansMono') { 'aporetic-sans-mono' }
                  elseif ($cleanFont -ieq 'AporeticSerifMono') { 'aporetic-serif-mono' }
                  elseif ($cleanFont -ieq 'PsudoFontLigaMono') { 'psudoFont_Liga_Mono' }
                  else { $cleanFont }
        $existing = @(Get-ChildItem $fontsDir -Filter "*$prefix*" -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.ttf', '.otf') })
        if ($existing.Count -gt 0) {
            Write-SKIP "$cleanFont (already installed - $($existing.Count) file(s))"
            foreach ($f in $existing) {
                $type = if ($f.Extension -ieq '.otf') { 'OpenType' } else { 'TrueType' }
                $regName = [System.IO.Path]::GetFileNameWithoutExtension($f.Name) + " ($type)"
                New-ItemProperty -Path $regPath -Name $regName -Value $f.FullName -PropertyType String -Force | Out-Null
            }
            continue
        }

        # Case 1: Custom direct download
        if ($customFonts.ContainsKey($lookupKey)) {
            $fileList = $customFonts[$lookupKey]
            Write-INFO "Downloading $cleanFont ($($fileList.Count) file(s) via curl)..."
            $successCount = 0
            foreach ($item in $fileList) {
                $dest = Join-Path $fontsDir $item.Filename
                if (-not (Test-Path $dest)) {
                    if ($item.ZipUrl) {
                        $tmpZ = Join-Path $env:TEMP "$($cleanFont)_custom.zip"
                        curl.exe -fLo $tmpZ -s $item.ZipUrl
                        if (Test-Path $tmpZ) {
                            $inner = if ($item.ZipInnerPath) { $item.ZipInnerPath } else { $item.Filename }
                            & tar.exe -xf $tmpZ -C $fontsDir $inner
                            $extracted = Join-Path $fontsDir $inner
                            if ((Test-Path $extracted) -and ($extracted -ne $dest)) {
                                Move-Item -Path $extracted -Destination $dest -Force -EA SilentlyContinue
                                # clean up subfolder if any
                                $subDir = Split-Path $extracted
                                if ($subDir -ne $fontsDir -and (Test-Path $subDir)) { Remove-Item $subDir -Recurse -Force -EA SilentlyContinue }
                            }
                            Remove-Item $tmpZ -Force -EA SilentlyContinue
                        }
                    } elseif ($item.Url) {
                        curl.exe -fLo $dest -s $item.Url
                    }
                }
                if (Test-Path $dest) {
                    New-ItemProperty -Path $regPath -Name $item.RegName -Value $dest -PropertyType String -Force | Out-Null
                    $successCount++
                }
            }
            if ($successCount -gt 0) {
                Write-OK "$cleanFont installed ($successCount files)."
            } else {
                Write-FAIL "$cleanFont download failed."
            }
            continue
        }

        # Case 2: Generic / Smart Nerd Font download (fetches archive & extracts both Standard and Mono TTFs/OTFs)
        Write-INFO "Downloading $cleanFont (Nerd Font Standard + Mono)..."
        $zipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$cleanFont.zip"
        $tmpZip = Join-Path $env:TEMP "$($cleanFont)_nf.zip"
        curl.exe -fLo $tmpZip -s $zipUrl
        if ($LASTEXITCODE -eq 0 -and (Test-Path $tmpZip)) {
            $allEntries = @(tar.exe -tf $tmpZip 2>$null)
            # Pick both Standard and Mono variants for Regular, Bold, Italic (ignore Propo and Windows-compatible bloat)
            $targets = @($allEntries | Where-Object {
                $_ -match '\.(ttf|otf)$' -and
                $_ -match '-(Regular|Bold|Italic)\.' -and
                $_ -notmatch '(Propo|Windows\s*Compatible)'
            })
            if (-not $targets -or $targets.Count -eq 0) {
                $targets = @($allEntries | Where-Object {
                    $_ -match '\.(ttf|otf)$' -and
                    $_ -match '(Regular|Bold|Italic)' -and
                    $_ -notmatch '(Propo|Windows\s*Compatible)'
                })
            }
            if (-not $targets -or $targets.Count -eq 0) {
                $targets = @($allEntries | Where-Object { $_ -match '\.(ttf|otf)$' -and $_ -notmatch 'Propo' } | Select-Object -First 4)
            }

            if ($targets -and $targets.Count -gt 0) {
                foreach ($t in $targets) {
                    & tar.exe -xf $tmpZip -C $fontsDir $t
                    $installedFile = Join-Path $fontsDir $t
                    if (Test-Path $installedFile) {
                        $ext = [System.IO.Path]::GetExtension($t)
                        $type = if ($ext -ieq '.otf') { 'OpenType' } else { 'TrueType' }
                        $regName = [System.IO.Path]::GetFileNameWithoutExtension($t) + " ($type)"
                        New-ItemProperty -Path $regPath -Name $regName -Value $installedFile -PropertyType String -Force | Out-Null
                    }
                }
                Remove-Item $tmpZip -Force -EA SilentlyContinue
                Write-OK "$cleanFont installed ($($targets.Count) files - Standard + Mono)."
            } else {
                Remove-Item $tmpZip -Force -EA SilentlyContinue
                Write-FAIL "$cleanFont archive did not contain recognizable TTF/OTF files."
            }
        } else {
            Remove-Item $tmpZip -Force -EA SilentlyContinue
            Write-FAIL "$cleanFont could not be downloaded (check font name spelling)."
        }
    }
}

# ==============================================================================
# MAIN
# ==============================================================================

Write-Host ""
Write-Host "+======================================================================+" -ForegroundColor DarkCyan
Write-Host "|         chezmoi run_once  -  post-apply package install              |" -ForegroundColor Cyan
Write-Host "+======================================================================+" -ForegroundColor DarkCyan
Write-Host ""

Update-SessionPath

$config = Get-PackageConfig
if (-not $config) { Write-FAIL "Cannot continue without packages.json."; exit 0 }

# Read profile from file setup.ps1 wrote -- avoids prompting twice in one run
$PROFILE_FILE = "$env:TEMP\dotfiles-profile-choice.txt"
$isFull = $false
if (Test-Path $PROFILE_FILE) {
    $saved = (Get-Content $PROFILE_FILE -Raw).Trim()
    $isFull = $saved -eq 'full'
    Write-SKIP "Using saved profile: $saved"
} else {
    $choice = ''
    while ($choice -notin @('mini','m','full','f')) {
        $choice = (Read-Host "     Install profile  [mini / full]").Trim().ToLower()
        if ($choice -notin @('mini','m','full','f')) { Write-Host "     Type 'mini' or 'full'." -ForegroundColor Red }
    }
    $isFull = $choice -in @('full','f')
    $profileVal = if ($isFull) { 'full' } else { 'mini' }
    Set-Content $PROFILE_FILE -Value $profileVal -Encoding ASCII
    Write-OK "Profile '$profileVal' saved."
}

$fontPkgs   = Get-Prop $config 'fonts'
$scoopPkgs  = if ($isFull) { Get-Prop $config.scoop  'full'   } else { Get-Prop $config.scoop  'mini'   }
$scoopGlob  = Get-Prop $config.scoop 'global'
$wingetPkgs = if ($isFull) { Get-Prop $config.winget 'full'   } else { Get-Prop $config.winget 'mini'   }

Invoke-ScoopPackages  -Desired $scoopPkgs -DesiredGlobal $scoopGlob
Invoke-WingetPackages -Desired $wingetPkgs
if ($isFull) { Invoke-PipEssentials }
Invoke-VSCodeExtensions
Invoke-PackagePins
Invoke-Fonts          -Desired $fontPkgs
if ($isFull) { Invoke-MachineDefaults }

Write-Host ""
Write-Host "+======================================================================+" -ForegroundColor DarkCyan
Write-Host "|                      run_once complete                               |" -ForegroundColor Cyan
Write-Host "+======================================================================+" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "     Managed manifest: $MANIFEST_PATH" -ForegroundColor DarkGray
Write-Host ""
Write-Host "     Add a package:    edit packages.json, run: chezmoi apply" -ForegroundColor DarkGray
Write-Host "     Remove a package: edit packages.json, run: chezmoi apply" -ForegroundColor DarkGray
Write-Host "     Manually installed packages are never auto-removed." -ForegroundColor DarkGray
Write-Host ""
