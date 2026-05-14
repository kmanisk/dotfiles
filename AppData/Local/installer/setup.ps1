#Requires -Version 5.1
<#
.SYNOPSIS
    kmanisk/dotfiles - All-in-one Windows bootstrap + package installer.
    Works as ADMIN or normal user. Resumes from where it left off on re-run.
#>
param([switch]$Reset)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# State file
$STATE_FILE = "$env:TEMP\dotfiles-setup-state.json"

function Get-State {
    if (Test-Path $STATE_FILE) {
        try { return (Get-Content $STATE_FILE -Raw | ConvertFrom-Json) }
        catch { }
    }
    return [PSCustomObject]@{ completed = @() }
}

function Set-StepDone {
    param([string]$Step)
    $s = Get-State
    if ($s.completed -notcontains $Step) {
        $s.completed += $Step
        $s | ConvertTo-Json | Set-Content $STATE_FILE -Encoding UTF8
    }
}

function Test-StepDone {
    param([string]$Step)
    return (Get-State).completed -contains $Step
}

if ($Reset) {
    Remove-Item $STATE_FILE -Force -ErrorAction SilentlyContinue
    Write-Host "State cleared  -  all steps will re-run." -ForegroundColor Yellow
}

# Display helpers (rewritten to avoid parser issues)
function Write-Banner {
    param([string]$Msg)
    $w = 70
    $pad = [math]::Max(0, $w - $Msg.Length - 4)
    $l = [math]::Floor($pad / 2)
    $r = $pad - $l
    Write-Host ""
    Write-Host ('+' + ('=' * ($w - 2)) + '+') -ForegroundColor DarkCyan
    Write-Host ("|  " + (' ' * $l) + $Msg + (' ' * $r) + "  |") -ForegroundColor Cyan
    Write-Host ('+' + ('=' * ($w - 2)) + '+') -ForegroundColor DarkCyan
    Write-Host ""
}

function Write-Section {
    param([string]$Msg)
    Write-Host ""
    Write-Host "  +- $Msg " -ForegroundColor DarkCyan -NoNewline
    $dashes = '-' * [math]::Max(2, 62 - $Msg.Length)
    Write-Host $dashes -ForegroundColor DarkCyan
    Write-Host ""
}

function Write-OK   { param([string]$m) Write-Host "     [OK]  $m" -ForegroundColor Green }
function Write-SKIP { param([string]$m) Write-Host "     [--]  $m" -ForegroundColor DarkYellow }
function Write-FAIL { param([string]$m) Write-Host "     [XX]  $m" -ForegroundColor Red }
function Write-INFO { param([string]$m) Write-Host "     ->  $m" -ForegroundColor Gray }
function Write-WARN { param([string]$m) Write-Host "     [!!]  $m" -ForegroundColor Yellow }

# Utilities
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
    )
    $machine = [Environment]::GetEnvironmentVariable('PATH', 'Machine') -split ';'
    $user    = [Environment]::GetEnvironmentVariable('PATH', 'User') -split ';'
    $env:PATH = (($prepend + $machine + $user) | Where-Object { $_ -and $_.Trim() -ne '' } | Select-Object -Unique) -join ';'
}

function Invoke-WithRetry {
    param([scriptblock]$Block, [int]$Tries = 3, [int]$DelaySec = 5)
    for ($i = 1; $i -le $Tries; $i++) {
        try { & $Block; return $true }
        catch {
            if ($i -lt $Tries) { Write-INFO "Attempt $i failed  -  retrying in ${DelaySec}s..."; Start-Sleep $DelaySec }
            else { Write-FAIL "All $Tries attempts failed: $_"; return $false }
        }
    }
}

function Repair-JsonContent {
    param([string]$Path)
    $content = Get-Content $Path -Raw
    $fixed = $content -replace ',(\s*[}\]])', '$1'
    return $fixed
}

# Step 1: Execution Policy
function Step-ExecutionPolicy {
    if (Test-StepDone 'ExecutionPolicy') { Write-SKIP "Execution policy already set."; return }
    Write-Section "Execution Policy"
    try {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        Write-OK "RemoteSigned set for current user."
    } catch {
        Write-WARN "Execution policy unchanged  -  continuing anyway."
    }
    Set-StepDone 'ExecutionPolicy'
}

# Step 2: Scoop
function Step-Scoop {
    Write-Section "Scoop Package Manager"
    if (-not $env:SCOOP) {
        $env:SCOOP = "$env:USERPROFILE\scoop"
        [Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
    }
    if (Test-Cmd 'scoop') {
        Write-SKIP "Scoop already installed."
        Update-SessionPath
        Set-StepDone 'Scoop'
        return
    }
    if (Test-StepDone 'Scoop') {
        Write-SKIP "Scoop install recorded  -  refreshing PATH."
        Update-SessionPath
        return
    }
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    $isAdmin = Get-IsAdmin
    if ($isAdmin) { Write-INFO "Admin session  -  using -RunAsAdmin flag." }
    else { Write-INFO "Normal user session  -  standard Scoop install." }

    $ok = Invoke-WithRetry -Tries 3 -Block {
        $inst = "$env:TEMP\scoop-install.ps1"
        Invoke-RestMethod -Uri 'https://get.scoop.sh' -OutFile $inst
        if ($isAdmin) { powershell -ExecutionPolicy Bypass -File $inst -RunAsAdmin }
        else { powershell -ExecutionPolicy Bypass -File $inst }
        Remove-Item $inst -Force -ErrorAction SilentlyContinue
        if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "Scoop installer exit $LASTEXITCODE" }
    }
    Update-SessionPath
    if (Test-Cmd 'scoop') {
        Write-OK "Scoop installed."
        Set-StepDone 'Scoop'
    } elseif ($ok) {
        Write-WARN "Scoop installed but not on PATH  -  open a new terminal if steps fail."
        Set-StepDone 'Scoop'
    } else {
        Write-FAIL "Scoop install failed. Check internet and re-run."
    }
}

# Step 3: Git
function Step-Git {
    Write-Section "Git (prerequisite for Scoop buckets)"
    if (-not (Test-Cmd 'scoop')) { Write-SKIP "Scoop not available  -  cannot install Git."; return }
    if (Test-Cmd 'git') {
        Write-SKIP "Git already installed."
        Set-StepDone 'Git'
        return
    }
    if (Test-StepDone 'Git') {
        Write-SKIP "Git install recorded  -  refreshing PATH."
        Update-SessionPath
        return
    }
    Write-INFO "Installing Git via Scoop..."
    scoop install git 2>&1 | Out-Null
    Update-SessionPath
    if (Test-Cmd 'git') {
        Write-OK "Git installed."
        Set-StepDone 'Git'
    } else {
        Write-FAIL "Git installation failed  -  buckets will not work."
    }
}

# Step 4: Scoop Buckets
function Step-ScoopBuckets {
    if (Test-StepDone 'ScoopBuckets') { Write-SKIP "Scoop buckets already configured."; return }
    Write-Section "Scoop Buckets"
    if (-not (Test-Cmd 'scoop')) { Write-SKIP "Scoop not available  -  skipping buckets."; return }
    if (-not (Test-Cmd 'git')) { Write-WARN "Git not available  -  skipping buckets (will retry after Git install)."; return }

    $official = @('main','extras','versions','nerd-fonts','java','games')
    $custom = [ordered]@{
        'volllly' = 'https://github.com/volllly/scoop-bucket.git'
        'shemnei' = 'https://github.com/Shemnei/scoop-bucket.git'
        'nonportable' = 'https://github.com/ScoopInstaller/Nonportable'
        'chawyehsu_dorado' = 'https://github.com/chawyehsu/dorado'
        'kkzzhizhou_scoop-apps' = 'https://github.com/kkzzhizhou/scoop-apps'
    }
    $existing = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    scoop bucket list 2>$null | ForEach-Object {
        $n = if ($_ -is [string]) { ($_ -split '\s+')[0] } elseif ($_.Name) { $_.Name } else { $null }
        if ($n -and $n -match '\S') { [void]$existing.Add($n) }
    }
    $allBuckets = $official + @($custom.Keys)
    $failed = $false
    foreach ($b in $allBuckets) {
        if ($existing.Contains($b)) { Write-SKIP "Bucket '$b'"; continue }
        Write-INFO "Adding bucket '$b'..."
        if ($custom.Contains($b)) { scoop bucket add $b $custom[$b] 2>&1 | Out-Null }
        else { scoop bucket add $b 2>&1 | Out-Null }
        # Re-query after add; handle both string (PS5.1) and object (PS7) output
        $addedOk = $false
        scoop bucket list 2>$null | ForEach-Object {
            $n = if ($_ -is [string]) { ($_ -split '\s+')[0] } elseif ($_.Name) { $_.Name } else { $null }
            if ($n -and $n -ieq $b) { $addedOk = $true }
        }
        if ($addedOk) { Write-OK "Bucket '$b' added."; [void]$existing.Add($b) }
        else { Write-FAIL "Bucket '$b' could not be added."; $failed = $true }
    }
    if (-not $failed) { Set-StepDone 'ScoopBuckets' }
    else { Write-WARN "Some buckets failed  -  re-run to retry." }
}

# Step 5: Python
function Step-Python {
    Write-Section "Python (via Scoop)"
    if (-not (Test-Cmd 'scoop')) { Write-SKIP "Scoop not available  -  skipping Python."; return }
    $pythonExe = "$env:USERPROFILE\scoop\apps\python\current\python.exe"
    if (Test-Path $pythonExe) {
        Write-SKIP "Python already installed."
    } else {
        Write-INFO "Installing Python (attempt 1/3)..."
        $installed = $false
        for ($i = 1; $i -le 3; $i++) {
            scoop install python 2>&1 | Out-Null
            if (Test-Path $pythonExe) { $installed = $true; break }
            Write-INFO "Retry $i/3  -  sleeping 5s..."
            Start-Sleep 5
        }
        if (-not $installed) {
            Write-FAIL "Scoop Python install failed  -  trying direct download as fallback..."
            $fallbackUrl = "https://www.python.org/ftp/python/3.14.4/python-3.14.4-amd64.exe"
            $fallbackExe = "$env:TEMP\python-installer.exe"
            try {
                Invoke-WebRequest -Uri $fallbackUrl -OutFile $fallbackExe -UseBasicParsing
                Start-Process -FilePath $fallbackExe -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1" -Wait
                Remove-Item $fallbackExe -Force -ErrorAction SilentlyContinue
                $pythonExe = "$env:ProgramFiles\Python314\python.exe"
                if (-not (Test-Path $pythonExe)) { $pythonExe = "$env:USERPROFILE\AppData\Local\Programs\Python\Python314\python.exe" }
                if (Test-Path $pythonExe) { Write-OK "Python installed via direct download." }
                else { Write-FAIL "Python fallback also failed."; return }
            } catch { Write-FAIL "Python fallback failed: $_"; return }
        } else {
            Write-OK "Python installed via Scoop."
        }
    }
    # Fix PATH priority
    $scoopPy = "$env:USERPROFILE\scoop\apps\python\current"
    $scoopScripts = "$scoopPy\Scripts"
    $winApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    $clean = ([Environment]::GetEnvironmentVariable('PATH','User') -split ';') | Where-Object { $_ -and $_ -ne $winApps -and $_ -ne $scoopPy -and $_ -ne $scoopScripts }
    [Environment]::SetEnvironmentVariable('PATH', (@($scoopPy,$scoopScripts) + $clean) -join ';', 'User')
    $regKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\python.exe'
    New-Item -Path $regKey -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $regKey -Name '(Default)' -Value $pythonExe -ErrorAction SilentlyContinue
    Remove-Item -Path 'Alias:\python' -ErrorAction SilentlyContinue
    Remove-Item -Path 'Function:\python' -ErrorAction SilentlyContinue
    Update-SessionPath
    Write-OK "Python ready."
    try { & $pythonExe --version } catch {}
    Set-StepDone 'Python'
}

# Step 6: Core Tools
function Step-CoreTools {
    Write-Section "Core Tools (aria2 * gh * chezmoi * pwsh)"
    if (-not (Test-Cmd 'scoop')) { Write-SKIP "Scoop not available  -  skipping core tools."; return }
    # aria2 installs its binary as aria2c, not aria2 -- map each tool to its real command
    $toolCmdMap = @{ aria2='aria2c'; gh='gh'; chezmoi='chezmoi'; pwsh='pwsh' }
    $tools = @('aria2','gh','chezmoi','pwsh')
    foreach ($t in $tools) {
        $cmd = $toolCmdMap[$t]
        $key = "CoreTool_$t"
        if ((Test-StepDone $key) -and (Test-Cmd $cmd)) { Write-SKIP $t; continue }
        if (Test-Cmd $cmd) { Write-SKIP $t; Set-StepDone $key; continue }
        Write-INFO "Installing $t..."
        # Avoid piping to Out-Null: $LASTEXITCODE gets clobbered by the pipeline on PS5.1
        # Capture output array, filter aria2 warnings, print the rest
        $installOut = @(scoop install $t 2>&1)
        $installOut | Where-Object { $_ -notmatch '^WARN.*aria2' } | ForEach-Object { Write-INFO "  $_" }
        Update-SessionPath
        if (Test-Cmd $cmd) { Write-OK "$t installed."; Set-StepDone $key }
        else { Write-FAIL "$t install failed  -  will retry on next run." }
    }
    if (Test-Cmd 'aria2c') {
        scoop config aria2-enabled true 2>&1 | Out-Null
        Write-INFO "Scoop aria2 enabled."
    }
}

# Step 7: Winget
function Step-Winget {
    Write-Section "Winget"
    if ((Test-StepDone 'Winget') -and (Test-Cmd 'winget')) { Write-SKIP "Winget already installed."; return }
    if (Test-Cmd 'winget') { Write-SKIP "Winget on PATH."; Set-StepDone 'Winget'; return }
    if (Test-Cmd 'scoop') {
        Write-INFO "Installing winget via Scoop extras/winget..."
        scoop install extras/winget 2>&1 | Out-Null
        Update-SessionPath
    }
    if (-not (Test-Cmd 'winget')) {
        Write-INFO "Trying PowerShell Gallery fallback..."
        try {
            Install-Script winget-install -Force -ErrorAction Stop
            winget-install -Force
            Update-SessionPath
        } catch { Write-WARN "PSGallery fallback failed: $_" }
    }
    # Win10: winget lands in WindowsApps which is not in the session PATH until new terminal
    $waPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    if ((Test-Path $waPath) -and ($env:PATH -notlike "*$waPath*")) {
        $env:PATH = "$waPath;$env:PATH"
    }
    Update-SessionPath
    if (Test-Cmd 'winget') { Write-OK "Winget installed."; Set-StepDone 'Winget' }
    else { Write-FAIL "Winget not found  -  install manually: https://aka.ms/getwinget" }
}

# Step 8: Chocolatey
function Step-Chocolatey {
    Write-Section "Chocolatey"
    if ((Test-StepDone 'Chocolatey') -and (Test-Cmd 'choco')) { Write-SKIP "Chocolatey already installed."; return }
    if (-not (Test-Cmd 'choco')) {
        Write-INFO "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        try {
            Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        } catch {
            Write-FAIL "Chocolatey install failed: $_  -  continuing without it."
            return
        }
        Update-SessionPath
        if (Test-Cmd 'choco') { Write-OK "Chocolatey installed." }
        else { Write-FAIL "choco not on PATH after install  -  restart terminal."; return }
    } else { Write-SKIP "Chocolatey already on PATH." }
    choco feature enable -n allowGlobalConfirmation -y 2>$null | Out-Null
    choco feature enable -n checksumFiles -y 2>$null | Out-Null
    choco feature enable -n allowEmptyChecksums -y 2>$null | Out-Null
    Write-OK "Chocolatey features configured."
    Set-StepDone 'Chocolatey'
}

# Step 9: Chezmoi Init
function Step-ChezmoiInit {
    Write-Section "Chezmoi Init"
    if (-not (Test-Cmd 'chezmoi')) {
        Write-FAIL "chezmoi not found  -  Step-CoreTools must complete first."
        return
    }
    $src = "$env:USERPROFILE\.local\share\chezmoi"
    if (Test-StepDone 'ChezmoiInit') {
        Write-SKIP "chezmoi already initialised  -  applying latest changes..."
        chezmoi apply
        return
    }
    if (Test-Path "$src\.git") { chezmoi apply }
    else { chezmoi init --apply kmanisk }
    if ($LASTEXITCODE -eq 0) { Write-OK "chezmoi applied."; Set-StepDone 'ChezmoiInit' }
    else { Write-WARN "chezmoi exited $LASTEXITCODE  -  re-run to retry." }
}

# Get package config
function Get-PackageConfig {
    $p = "$env:USERPROFILE\.local\share\chezmoi\AppData\Local\installer\packages.json"
    if (-not (Test-Path $p)) {
        Write-FAIL "packages.json not found  -  chezmoi init must complete first."
        return $null
    }
    try {
        $fixedJson = Repair-JsonContent -Path $p
        $cfg = $fixedJson | ConvertFrom-Json
        Write-OK "packages.json loaded (fixed)."
        return $cfg
    } catch {
        Write-FAIL "Failed to parse packages.json: $_"
        return $null
    }
}

# Installers
function Install-ScoopPackages {
    param([array]$UserPackages = @(), [array]$GlobalPackages = @())
    Write-Section "Scoop Packages"
    if (-not (Test-Cmd 'scoop')) { Write-SKIP "Scoop not available."; return }

    # Build installed sets once upfront
    $instUser   = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $instGlobal = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    scoop list 2>$null | Select-Object -Skip 1 | ForEach-Object {
        $n = if ($_ -is [string]) { ($_ -split '\s+')[0] } else { $_.Name }
        if ($n) { [void]$instUser.Add($n) }
    }
    # scoop list --global returns objects on PS7 and strings on PS5.1 -- handle both
    @(scoop list --global 2>$null) | ForEach-Object {
        $n = if ($_ -is [string]) { ($_ -split '\s+')[0] } elseif ($_.Name) { $_.Name } else { $null }
        if ($n -and $n -match '\S' -and $n -notmatch '^(Name|---)') { [void]$instGlobal.Add($n) }
    }

    # Collect packages into two buckets: need install vs need update
    $toInstall = [System.Collections.Generic.List[string]]::new()
    $toUpdate  = [System.Collections.Generic.List[string]]::new()

    foreach ($pkg in $UserPackages) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        $short = ($pkg -split '/')[-1]
        if ($instUser.Contains($short)) { $toUpdate.Add($short) }
        else                            { $toInstall.Add($pkg)  }
    }

    # Install missing packages
    if ($toInstall.Count -gt 0) {
        Write-INFO "Installing $($toInstall.Count) new package(s)..."
        foreach ($pkg in $toInstall) {
            $short = ($pkg -split '/')[-1]
            Write-INFO "scoop install $pkg"
            scoop install $pkg 2>&1 | Where-Object { $_ -notmatch 'aria2' } | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-OK "$short installed."; [void]$instUser.Add($short) }
            else                     { Write-FAIL "$short install failed  -  will retry on next run." }
        }
    }

    # Update already-installed packages
    if ($toUpdate.Count -gt 0) {
        Write-INFO "Updating $($toUpdate.Count) already-installed package(s)..."
        foreach ($short in $toUpdate) {
            Write-INFO "scoop update $short"
            # Collect as array then join -- Out-String can drop stderr lines on PS5.1
            $outLines = @(scoop update $short 2>&1)
            $outStr   = $outLines -join "`n"
            if ($outStr -match '(latest version|already up to date|Latest versions for all apps are installed)') {
                Write-SKIP "$short (already up to date)"
            } elseif ($outStr -match 'ERROR|FAIL' -or ($LASTEXITCODE -and $LASTEXITCODE -ne 0)) {
                Write-WARN "$short update failed  -  run 'scoop update $short' manually."
            } else {
                Write-OK "$short updated."
            }
        }
    }

    # Global packages (fonts etc - need admin)
    $toInstallGlob = [System.Collections.Generic.List[string]]::new()
    $toUpdateGlob  = [System.Collections.Generic.List[string]]::new()

    foreach ($pkg in $GlobalPackages) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        $short = ($pkg -split '/')[-1]
        if ($instGlobal.Contains($short)) { $toUpdateGlob.Add($short) }
        else                              { $toInstallGlob.Add($pkg)  }
    }

    $isAdmin = Get-IsAdmin

    foreach ($pkg in $toInstallGlob) {
        $short = ($pkg -split '/')[-1]
        if (-not $isAdmin) { Write-WARN "$short (global)  -  re-run as Administrator to install."; continue }
        Write-INFO "scoop install --global $pkg"
        scoop install --global $pkg 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-OK "$short (global) installed."; [void]$instGlobal.Add($short) }
        else                     { Write-FAIL "$short (global) failed  -  will retry on next run." }
    }

    foreach ($short in $toUpdateGlob) {
        if (-not $isAdmin) { Write-WARN "$short (global)  -  re-run as Administrator to update."; continue }
        Write-INFO "scoop update $short (global)"
        $outLines = @(scoop update $short --global 2>&1)
        $outStr   = $outLines -join "`n"
        if ($outStr -match '(latest version|already up to date|Latest versions for all apps are installed)') {
            Write-SKIP "$short (global, already up to date)"
        } elseif ($outStr -match 'ERROR|FAIL' -or ($LASTEXITCODE -and $LASTEXITCODE -ne 0)) {
            Write-WARN "$short (global) update failed  -  run 'scoop update $short --global' manually."
        } else {
            Write-OK "$short (global) updated."
        }
    }

    Update-SessionPath
}

function Install-WingetPackages {
    param([string[]]$Packages = @())
    Write-Section "Winget Packages"
    if (-not (Test-Cmd 'winget')) { Write-SKIP "Winget not available."; return }
    $installedRaw = winget list --accept-source-agreements 2>$null | Out-String
    foreach ($pkg in $Packages) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        $key = "Winget_$($pkg -replace '[^\w]','_')"
        if (Test-StepDone $key) { Write-SKIP $pkg; continue }
        if ($installedRaw -match [regex]::Escape($pkg)) { Write-SKIP $pkg; Set-StepDone $key; continue }
        Write-INFO "winget install $pkg"
        winget install --id $pkg --source winget --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-OK $pkg; Set-StepDone $key }
        else { Write-FAIL "$pkg  -  will retry on next run." }
    }
}

function Install-ChocoPackages {
    param([string[]]$Packages = @())
    Write-Section "Chocolatey Packages"
    if (-not (Test-Cmd 'choco')) { Write-SKIP "Chocolatey not available."; return }
    $instChoco = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    choco list 2>$null | ForEach-Object {
        if ($_ -match '^(\S+)\s+\S') { [void]$instChoco.Add($matches[1]) }
    }
    $batch = [System.Collections.Generic.List[string]]::new()
    $versioned = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($pkg in $Packages) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        if ($pkg -match '^(.+?)\s+--version[= ](\S+)$') {
            $name = $matches[1].Trim(); $ver = $matches[2].Trim()
            $key = "Choco_${name}_$ver"
            if ((Test-StepDone $key) -or $instChoco.Contains($name)) { Write-SKIP $name; Set-StepDone $key; continue }
            $versioned.Add(@{ Name=$name; Version=$ver; Key=$key })
        } else {
            $key = "Choco_$($pkg -replace '[^\w]','_')"
            if ((Test-StepDone $key) -or $instChoco.Contains($pkg)) { Write-SKIP $pkg; Set-StepDone $key; continue }
            $batch.Add($pkg)
        }
    }
    if ($batch.Count -gt 0) {
        Write-INFO "Batch installing: $($batch -join ', ')"
        choco install @batch -y 2>&1 | Out-Null
        $nowInstalled = choco list 2>$null | Out-String
        foreach ($p in $batch) {
            $key = "Choco_$($p -replace '[^\w]','_')"
            if ($nowInstalled -match "(?m)^$([regex]::Escape($p))\s") { Write-OK $p; Set-StepDone $key }
            else { Write-FAIL "$p  -  will retry on next run." }
        }
    }
    foreach ($v in $versioned) {
        Write-INFO "choco install $($v.Name) --version=$($v.Version)"
        choco install $v.Name --version=$($v.Version) -y 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-OK $v.Name; Set-StepDone $v.Key }
        else { Write-FAIL "$($v.Name)  -  will retry on next run." }
    }
}

function Install-PipEssentials {
    Write-Section "pip Packages"
    if (Test-StepDone 'PipEssentials') { Write-SKIP "pip packages already installed."; return }
    $py = "$env:USERPROFILE\scoop\apps\python\current\python.exe"
    if (-not (Test-Path $py)) { $py = if (Test-Cmd 'python') { 'python' } else { $null } }
    if (-not $py) { Write-FAIL "Python not found."; return }
    & $py -m pip install --upgrade pip --quiet 2>$null
    foreach ($p in @('gdown')) {
        if (& $py -m pip show $p 2>$null) { Write-SKIP $p }
        else { & $py -m pip install $p --quiet; Write-OK "$p installed." }
    }
    Set-StepDone 'PipEssentials'
}

function Step-VSCodeExtensions {
    Write-Section "VSCode / VSCodium Extensions"
    if (Test-StepDone 'VSCodeExtensions') { Write-SKIP "Extensions already installed."; return }
    $jsonPath = "$env:USERPROFILE\.local\share\chezmoi\AppData\Local\installer\vscode.json"
    if (-not (Test-Path $jsonPath)) { Write-SKIP "vscode.json not found  -  skipping sync."; return }
    $json = Get-Content $jsonPath -Raw | ConvertFrom-Json
    $updated = $false
    foreach ($editor in @(@{ Cmd='code'; Key='vscode' }, @{ Cmd='codium'; Key='vscodium' })) {
        if (Test-Cmd $editor.Cmd) {
            $current = & $editor.Cmd --list-extensions 2>$null
            if ($current -ne $json.($editor.Key)) {
                $json.($editor.Key) = $current
                $updated = $true
                Write-OK "$($editor.Key) extensions updated in vscode.json."
            } else {
                Write-SKIP "$($editor.Key) extensions already up-to-date."
            }
        }
    }
    if ($updated) {
        $json | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath -Encoding UTF8
    }
    Set-StepDone 'VSCodeExtensions'
}

function Step-Pins {
    Write-Section "Package Pins"
    if (Test-StepDone 'Pins') { Write-SKIP "Pins already configured."; return }
    if (Test-Cmd 'choco') {
        $pinned = choco pin list 2>$null | Out-String
        foreach ($p in @('zoxide','autohotkey')) {
            if ($pinned -match [regex]::Escape($p)) { Write-SKIP "$p pinned (choco)" }
            elseif ((choco list 2>$null | Out-String) -match "(?m)^$([regex]::Escape($p))\s") {
                choco pin add -n $p 2>$null | Out-Null; Write-OK "$p pinned (choco)"
            } else { Write-INFO "$p not installed  -  skipping choco pin" }
        }
    }
    if (Test-Cmd 'winget') {
        $pinnedW = winget pin list 2>$null | Out-String
        foreach ($id in @('AutoHotkey.AutoHotkey','Spotify.Spotify','OliverSchwendener.ueli')) {
            if ($pinnedW -match [regex]::Escape($id)) { Write-SKIP "$id pinned (winget)" }
            else {
                $inst = (winget list --id $id --accept-source-agreements 2>$null | Out-String) -match [regex]::Escape($id)
                if (-not $inst) {
                    winget install --id $id --source winget --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
                }
                winget pin add --id $id 2>$null | Out-Null
                Write-OK "$id pinned (winget)"
            }
        }
    }
    Set-StepDone 'Pins'
}

function Step-MachineDefaults {
    Write-Section "Machine Defaults"
    if (Test-StepDone 'MachineDefaults') { Write-SKIP "Machine defaults already applied."; return }
    $admin = Get-IsAdmin
    if ((Get-TimeZone).Id -ne 'India Standard Time') {
        try { Set-TimeZone -Name 'India Standard Time'; Write-OK "Timezone -> IST." }
        catch { Write-FAIL "Timezone: $_" }
    } else { Write-SKIP "Timezone already IST." }
    if ($admin) {
        $cbReg = 'HKLM:\SYSTEM\CurrentControlSet\Services\cbdhsvc'
        if (Test-Path $cbReg) {
            if ((Get-ItemProperty $cbReg 'Start' -EA SilentlyContinue).Start -ne 4) {
                try { Set-ItemProperty $cbReg 'Start' 4 -Force; Write-OK "Clipboard service disabled." }
                catch { Write-FAIL "Clipboard reg: $_" }
            } else { Write-SKIP "Clipboard service already disabled." }
        }
        $polReg = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
        if (-not (Test-Path $polReg)) { New-Item $polReg -Force | Out-Null }
        if ((Get-ItemProperty $polReg 'AllowClipboardHistory' -EA SilentlyContinue).AllowClipboardHistory -ne 0) {
            Set-ItemProperty $polReg 'AllowClipboardHistory' 0 -Type DWord
            Write-OK "Clipboard history policy disabled."
        } else { Write-SKIP "Clipboard history already disabled." }
    } else { Write-INFO "Skipping clipboard registry (not admin)." }
    if ($admin) {
        if ((wsl --status 2>&1 | Out-String) -match 'Default Version') { Write-SKIP "WSL already installed." }
        else {
            dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart 2>&1 | Out-Null
            dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart 2>&1 | Out-Null
            wsl --set-default-version 2 2>&1 | Out-Null
            Write-OK "WSL2 enabled (reboot required)."
        }
    } else { Write-INFO "Skipping WSL2 (not admin)." }
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
                Write-OK "$($_.Name) -> startup"
            } else { Write-SKIP "$($_.Name) already in startup." }
        }
    }
    $spotExe = "$env:APPDATA\Spotify\spotify.exe"
    if (-not (Test-Path $spotExe)) {
        Write-INFO "Installing Spotify via SpotX..."
        Set-MpPreference -DisableRealtimeMonitoring $true -EA SilentlyContinue
        $spotXScript = "$env:TEMP\spotx-run.ps1"
        Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1' -OutFile $spotXScript
        powershell -ExecutionPolicy Bypass -File $spotXScript -new_theme
        Remove-Item $spotXScript -Force -ErrorAction SilentlyContinue
        Set-MpPreference -DisableRealtimeMonitoring $false -EA SilentlyContinue
        Write-OK "Spotify installed."
    } else { Write-SKIP "Spotify already installed." }
    Set-StepDone 'MachineDefaults'
}

function Step-WindowsActivation {
    Write-Section "Windows Activation"

    if (Test-StepDone 'WindowsActivation') { Write-SKIP "Activation check already done this session."; return }

    # Query the Software Licensing Service for activation status
    $licenseStatus = $null
    try {
        $licenseStatus = (Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND ApplicationId='55c92734-d682-4d71-983e-d6ec3f16059f'" -ErrorAction Stop |
            Where-Object { $_.LicenseStatus -ne $null } |
            Select-Object -First 1).LicenseStatus
    } catch {
        Write-WARN "Could not query license status: $_"
    }

    # LicenseStatus 1 = Licensed (activated)
    if ($licenseStatus -eq 1) {
        Write-SKIP "Windows is already activated."
        Set-StepDone 'WindowsActivation'
        return
    }

    Write-WARN "Windows is NOT activated (LicenseStatus = $licenseStatus)."
    Write-INFO "Running Microsoft Activation Scripts (MAS)..."
    Write-INFO "Source: https://massgrave.dev"
    Write-Host ""

    try {
        $masScript = "$env:TEMP\mas-activate.ps1"
        Invoke-RestMethod -Uri 'https://get.activated.win' -OutFile $masScript
        powershell -ExecutionPolicy Bypass -File $masScript
        Remove-Item $masScript -Force -ErrorAction SilentlyContinue
        Write-OK "MAS activation script completed."
    } catch {
        Write-FAIL "MAS download/run failed: $_"
        Write-INFO "Run manually: irm https://get.activated.win | iex"
    }

    Set-StepDone 'WindowsActivation'
}

function Step-Verify {
    Write-Section "Verification"
    Update-SessionPath
    $missing = $false
    foreach ($r in @(
        @{Cmd='scoop'; Label='Scoop'}
        @{Cmd='git'; Label='Git'}
        @{Cmd='chezmoi'; Label='Chezmoi'}
        @{Cmd='aria2c'; Label='aria2'}
        @{Cmd='python'; Label='Python'}
        @{Cmd='winget'; Label='Winget'}
        @{Cmd='choco'; Label='Chocolatey'}
        @{Cmd='pwsh'; Label='PowerShell 7'}
    )) {
        if (Test-Cmd $r.Cmd) { Write-OK $r.Label }
        else { Write-WARN "$($r.Label)  -  not on PATH yet"; $missing = $true }
    }
    if ($missing) {
        Write-Host ""
        Write-Host "     Open a NEW terminal and re-run  -  already-done steps skip instantly." -ForegroundColor Yellow
    }
}

# MAIN
Write-Banner "kmanisk/dotfiles  -  All-in-One Windows Setup"

$isAdmin = Get-IsAdmin
Write-Host "     Session: $(if ($isAdmin) { 'Administrator (Scoop will use -RunAsAdmin)' } else { 'Normal user' })" -ForegroundColor $(if ($isAdmin) { 'Cyan' } else { 'DarkGray' })
Write-Host "     State:   $STATE_FILE" -ForegroundColor DarkGray
Write-Host "     Tip:     Pass -Reset to clear state and re-run all steps." -ForegroundColor DarkGray
Write-Host ""

Step-ExecutionPolicy
Step-Scoop
Step-Git
Step-ScoopBuckets
Step-Python
Step-CoreTools
Step-Winget
Step-Chocolatey
Update-SessionPath

Step-ChezmoiInit
Step-WindowsActivation

# Profile choice saved to a temp file so run_once_after_apply.ps1 reads it instead of asking again.
Write-Section "Install Profile"
$PROFILE_FILE = "$env:TEMP\dotfiles-profile-choice.txt"
$isFull = $false
if (-not (Test-Path $PROFILE_FILE)) {
    $choice = ''
    while ($choice -notin @('mini','m','full','f')) {
        $choice = (Read-Host "     Profile  [mini / full]").Trim().ToLower()
        if ($choice -notin @('mini','m','full','f')) { Write-Host "     Type 'mini' or 'full'." -ForegroundColor Red }
    }
    $isFull = $choice -in @('full','f')
    $profileVal = if ($isFull) { 'full' } else { 'mini' }
    Set-Content $PROFILE_FILE -Value $profileVal -Encoding ASCII
    Write-OK "Profile '$profileVal' saved  -  chezmoi run_once will use this automatically."
} else {
    $saved = (Get-Content $PROFILE_FILE -Raw).Trim()
    $isFull = $saved -eq 'full'
    Write-SKIP "Profile already chosen: $saved (delete $PROFILE_FILE to re-choose)"
}

Step-Verify

Write-Banner "Setup Complete"
Write-Host "     Open a new terminal to pick up all PATH changes." -ForegroundColor White
Write-Host ""
Write-Host "     Sync dotfiles anytime:           chezmoi apply" -ForegroundColor Green
Write-Host "     Update all packages:" -ForegroundColor Green
Write-Host "         scoop update *" -ForegroundColor Green
Write-Host "         choco upgrade all -y" -ForegroundColor Green
Write-Host "         winget upgrade --all" -ForegroundColor Green
Write-Host ""
Write-Host "     Re-run to retry any failed steps:" -ForegroundColor DarkGray
Write-Host "         .\setup.ps1" -ForegroundColor DarkGray
Write-Host "     Re-run everything from scratch:" -ForegroundColor DarkGray
Write-Host "         .\setup.ps1 -Reset" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  +------------------------------------------------------------+" -ForegroundColor DarkGray
Write-Host "  | Want a clean debloated Windows? Run Chris Titus WinUtil:  |" -ForegroundColor DarkGray
Write-Host "  |   irm https://christitus.com/win | iex                    |" -ForegroundColor DarkGray
Write-Host "  +------------------------------------------------------------+" -ForegroundColor DarkGray
Write-Host ""
Write-Host ""
