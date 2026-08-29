#Requires -Version 5.1
<#
.SYNOPSIS
    Automated installation and live activation script for Windows 10 Aero cursor scheme.
.DESCRIPTION
    Checks if the Windows 10 Aero cursor pack is already installed and active.
    If not, installs cursor files to %WINDIR%\Cursors\Windows 10 Aero, registers the scheme
    in the Windows Registry, and applies it live without requiring a restart or sign-out.
#>

[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SCHEME_NAME = 'Windows 10 Aero'
$SOURCE_DIR  = $PSScriptRoot
$TARGET_DIR  = "$env:WINDIR\Cursors\Windows 10 Aero"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $TARGET_DIR = "$env:LOCALAPPDATA\Cursors\Windows 10 Aero"
}

$CURSOR_FILES = @{
    'Arrow'       = 'aero_arrow.cur'
    'Help'        = 'aero_helpsel.cur'
    'AppStarting' = 'aero_working.ani'
    'Wait'        = 'aero_busy.ani'
    'Crosshair'   = 'cross_r.cur'
    'IBeam'       = 'beam_r.cur'
    'NWPen'       = 'aero_pen.cur'
    'No'          = 'aero_unavail.cur'
    'SizeNS'      = 'aero_ns.cur'
    'SizeWE'      = 'aero_ew.cur'
    'SizeNWSE'    = 'aero_nwse.cur'
    'SizeNESW'    = 'aero_nesw.cur'
    'SizeAll'     = 'aero_move.cur'
    'UpArrow'     = 'aero_up.cur'
    'Hand'        = 'aero_link.cur'
}

function Test-CursorInstalled {
    if (-not (Test-Path $TARGET_DIR)) { return $false }
    foreach ($file in $CURSOR_FILES.Values) {
        if (-not (Test-Path "$TARGET_DIR\$file")) { return $false }
    }

    $schemesKey = 'HKCU:\Control Panel\Cursors\Schemes'
    if (-not (Test-Path $schemesKey)) { return $false }
    $schemeVal = (Get-ItemProperty -Path $schemesKey -Name $SCHEME_NAME -ErrorAction SilentlyContinue).$SCHEME_NAME
    if (-not $schemeVal) { return $false }

    $cursorsKey = 'HKCU:\Control Panel\Cursors'
    $currentArrow = (Get-ItemProperty -Path $cursorsKey -Name 'Arrow' -ErrorAction SilentlyContinue).Arrow
    if ($currentArrow -ne "$TARGET_DIR\$($CURSOR_FILES['Arrow'])") { return $false }

    return $true
}

function Install-AeroCursor {
    Write-Host "  -> Installing Windows 10 Aero cursor scheme..." -ForegroundColor Cyan

    if (-not (Test-Path $TARGET_DIR)) {
        New-Item -ItemType Directory -Path $TARGET_DIR -Force | Out-Null
    }

    foreach ($file in $CURSOR_FILES.Values) {
        $srcFile = Join-Path $SOURCE_DIR $file
        if (Test-Path $srcFile) {
            Copy-Item -Path $srcFile -Destination "$TARGET_DIR\$file" -Force
        } else {
            Write-Warning "Source cursor file missing: $srcFile"
        }
    }

    $schemeString = @(
        "$TARGET_DIR\$($CURSOR_FILES['Arrow'])",
        "$TARGET_DIR\$($CURSOR_FILES['Help'])",
        "$TARGET_DIR\$($CURSOR_FILES['AppStarting'])",
        "$TARGET_DIR\$($CURSOR_FILES['Wait'])",
        "$TARGET_DIR\$($CURSOR_FILES['Crosshair'])",
        "$TARGET_DIR\$($CURSOR_FILES['IBeam'])",
        "$TARGET_DIR\$($CURSOR_FILES['NWPen'])",
        "$TARGET_DIR\$($CURSOR_FILES['No'])",
        "$TARGET_DIR\$($CURSOR_FILES['SizeNS'])",
        "$TARGET_DIR\$($CURSOR_FILES['SizeWE'])",
        "$TARGET_DIR\$($CURSOR_FILES['SizeNWSE'])",
        "$TARGET_DIR\$($CURSOR_FILES['SizeNESW'])",
        "$TARGET_DIR\$($CURSOR_FILES['SizeAll'])",
        "$TARGET_DIR\$($CURSOR_FILES['UpArrow'])",
        "$TARGET_DIR\$($CURSOR_FILES['Hand'])"
    ) -join ','

    $schemesKey = 'HKCU:\Control Panel\Cursors\Schemes'
    if (-not (Test-Path $schemesKey)) { New-Item -Path $schemesKey -Force | Out-Null }
    Set-ItemProperty -Path $schemesKey -Name $SCHEME_NAME -Value $schemeString -Type String

    $cursorsKey = 'HKCU:\Control Panel\Cursors'
    if (-not (Test-Path $cursorsKey)) { New-Item -Path $cursorsKey -Force | Out-Null }
    Set-ItemProperty -Path $cursorsKey -Name '(Default)' -Value $SCHEME_NAME -Type String
    Set-ItemProperty -Path $cursorsKey -Name 'Scheme Source' -Value 1 -Type DWord

    foreach ($entry in $CURSOR_FILES.GetEnumerator()) {
        Set-ItemProperty -Path $cursorsKey -Name $entry.Key -Value "$TARGET_DIR\$($entry.Value)" -Type String
    }

    $sig = '[DllImport("user32.dll", EntryPoint = "SystemParametersInfoW", SetLastError = true)] public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);'
    $reloader = Add-Type -MemberDefinition $sig -Name 'CursorReloader' -Namespace 'Win32' -PassThru -ErrorAction SilentlyContinue
    if ($reloader) {
        $reloader::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0x03) | Out-Null
    }

    Write-Host "     [OK]  Windows 10 Aero cursor scheme successfully installed and activated!" -ForegroundColor Green
}

if ($Force -or -not (Test-CursorInstalled)) {
    Install-AeroCursor
} else {
    Write-Host "     [--]  Windows 10 Aero cursor scheme is already installed and active." -ForegroundColor DarkYellow
}
