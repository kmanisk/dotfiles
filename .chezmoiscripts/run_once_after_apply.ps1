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
# CHOCOLATEY - declarative
# ==============================================================================

function Invoke-ChocoPackages {
    param([string[]]$Desired = @())
    Write-Section "Chocolatey Packages"
    if (-not (Test-Cmd 'choco')) { Write-SKIP "Chocolatey not available."; return }

    $manifest  = Get-Manifest
    $instChoco = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    choco list 2>$null | ForEach-Object {
        if ($_ -match '^(\S+)\s+\S') { [void]$instChoco.Add($matches[1]) }
    }

    # Build desired names set (strip --version=x suffix)
    $desiredNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($pkg in $Desired) {
        $name = if ($pkg -match '^(.+?)\s+--version') { $matches[1].Trim() } else { $pkg.Trim() }
        [void]$desiredNames.Add($name)
    }

    # Declarative uninstall (only what we previously managed)
    foreach ($prev in @($manifest.choco)) {
        if (-not $desiredNames.Contains($prev) -and $instChoco.Contains($prev)) {
            Write-INFO "Removing $prev (no longer in packages.json)..."
            choco uninstall $prev -y 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-OK "$prev uninstalled."; [void]$instChoco.Remove($prev) }
            else { Write-WARN "$prev uninstall failed." }
        }
    }

    # Install missing
    $batch    = [System.Collections.Generic.List[string]]::new()
    $versioned = [System.Collections.Generic.List[hashtable]]::new()

    foreach ($pkg in $Desired) {
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
        Write-INFO "Batch installing: $($batch -join ', ')"
        choco install @batch -y 2>&1 | Out-Null
        $nowInstalled = choco list 2>$null | Out-String
        foreach ($p in $batch) {
            if ($nowInstalled -match "(?m)^$([regex]::Escape($p))\s") { Write-OK $p }
            else { Write-FAIL "$p failed." }
        }
    }

    foreach ($v in $versioned) {
        Write-INFO "choco install $($v.Name) --version=$($v.Version)"
        choco install $v.Name --version=$($v.Version) -y 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-OK $v.Name } else { Write-FAIL "$($v.Name) failed." }
    }

    $manifest.choco = @($desiredNames)
    Save-Manifest $manifest
}

# ==============================================================================
# PIP
# ==============================================================================

function Invoke-PipEssentials {
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
    if (Test-Cmd 'choco') {
        $pinned = choco pin list 2>$null | Out-String
        foreach ($p in @('zoxide')) {
            if ($pinned -match [regex]::Escape($p)) { Write-SKIP "$p (choco, pinned)" }
            elseif ((choco list 2>$null | Out-String) -match "(?m)^$([regex]::Escape($p))\s") {
                choco pin add -n $p 2>$null | Out-Null; Write-OK "$p pinned (choco)"
            } else { Write-INFO "$p not installed - skipping pin" }
        }
    }
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
        if ((Get-ItemProperty $polReg 'AllowClipboardHistory' -EA SilentlyContinue).AllowClipboardHistory -ne 0) {
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
        Set-MpPreference -DisableRealtimeMonitoring $true -EA SilentlyContinue
        $s = "$env:TEMP\spotx-run.ps1"
        Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1' -OutFile $s
        powershell -ExecutionPolicy Bypass -File $s -new_theme
        Remove-Item $s -Force -EA SilentlyContinue
        Set-MpPreference -DisableRealtimeMonitoring $false -EA SilentlyContinue
        Write-OK "Spotify installed."
    } else { Write-SKIP "Spotify already installed." }
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

$scoopPkgs  = if ($isFull) { Get-Prop $config.scoop  'full'   } else { Get-Prop $config.scoop  'mini'   }
$scoopGlob  = Get-Prop $config.scoop 'global'
$wingetPkgs = if ($isFull) { Get-Prop $config.winget 'full'   } else { Get-Prop $config.winget 'mini'   }
$chocoPkgs  = if ($isFull) { Get-Prop $config.choco  'full'   } else { Get-Prop $config.choco  'mini'   }

Invoke-ScoopPackages  -Desired $scoopPkgs -DesiredGlobal $scoopGlob
Invoke-WingetPackages -Desired $wingetPkgs
Invoke-ChocoPackages  -Desired $chocoPkgs
if ($isFull) { Invoke-PipEssentials }
Invoke-VSCodeExtensions
Invoke-PackagePins
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
