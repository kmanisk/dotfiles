<#
.SYNOPSIS
    Disable-ExplorerGroupBy.ps1
    Permanently disables "Group By" (sets to None) across ALL folder types in Windows 10 & 11.
#>

param(
    [switch]$NoRestart
)

$ErrorActionPreference = "Continue"

Write-Host "`n+======================================================================+" -ForegroundColor Cyan
Write-Host "|   Disable File Explorer 'Group By' Globally (Windows 10 & 11)       |" -ForegroundColor Cyan
Write-Host "+======================================================================+`n" -ForegroundColor Cyan

# 1. Registry paths
# FIX: the HKCU override must mirror the HKLM path EXACTLY (same subtree,
# just a different hive root). It is NOT nested under Shell\Bags — that
# branch only holds per-folder view *cache*, not FolderType overrides.
$hklmFolderTypes = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes"
$hkcuFolderTypes = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes"

$hkcuShell   = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell"
$hkcuBags    = "$hkcuShell\Bags"
$hkcuBagMRU  = "$hkcuShell\BagMRU"
$hkcuStreams = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Defaults"

# 2. Reset legacy cached folder view bags
Write-Host "  -> [1/5] Clearing cached folder views..." -ForegroundColor Yellow
Remove-Item -Path $hkcuBags -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $hkcuBagMRU -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $hkcuStreams -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "     [OK] Legacy cached views cleared." -ForegroundColor Green

# 3. Create HKCU FolderTypes override container
if (-not (Test-Path $hkcuFolderTypes)) {
    New-Item -Path $hkcuFolderTypes -Force | Out-Null
}

# 4. Mirror all HKLM FolderTypes to HKCU and blank GroupBy on all TopViews
Write-Host "  -> [2/5] Applying GroupBy: (None) override across all FolderTypes..." -ForegroundColor Yellow
$folderTypes = Get-ChildItem -Path $hklmFolderTypes -ErrorAction SilentlyContinue
$patchedCount = 0

foreach ($ft in $folderTypes) {
    $ftGuid = $ft.PSChildName
    $hklmTopViews = Join-Path $ft.PSPath "TopViews"

    if (Test-Path $hklmTopViews) {
        $topViews = Get-ChildItem -Path $hklmTopViews -ErrorAction SilentlyContinue
        foreach ($tv in $topViews) {
            $tvGuid = $tv.PSChildName
            $targetTopViewPath = "$hkcuFolderTypes\$ftGuid\TopViews\$tvGuid"

            if (-not (Test-Path $targetTopViewPath)) {
                New-Item -Path $targetTopViewPath -Force | Out-Null
            }

            # Copy all properties from HKLM TopView, then blank GroupBy
            $props = (Get-ItemProperty -Path $tv.PSPath).psobject.properties
            foreach ($p in $props) {
                if ($p.Name -notmatch "^(PS|psobject)") {
                    Set-ItemProperty -Path $targetTopViewPath -Name $p.Name -Value $p.Value -Force -ErrorAction SilentlyContinue
                }
            }

            # Disable GroupBy permanently
            Set-ItemProperty -Path $targetTopViewPath -Name "GroupBy" -Value "" -Type String -Force
            Set-ItemProperty -Path $targetTopViewPath -Name "GroupAscending" -Value "TRUE" -Type String -Force
            $patchedCount++
        }
    }
}

Write-Host "     [OK] Patched $patchedCount TopView templates across $($folderTypes.Count) FolderTypes." -ForegroundColor Green

# 5. Set default stream settings
Write-Host "  -> [3/5] Configuring default stream settings..." -ForegroundColor Yellow
if (-not (Test-Path $hkcuStreams)) { New-Item -Path $hkcuStreams -Force | Out-Null }
Write-Host "     [OK] Default streams configured." -ForegroundColor Green

# 6. Clear UWP/Store app view cache (Notepad, Paint, other packaged apps)
#    so their Open/Save dialogs pick up the change too.
Write-Host "  -> [4/5] Clearing packaged-app view cache..." -ForegroundColor Yellow
$pkgs = "$env:LocalAppData\Packages"
if (Test-Path $pkgs) {
    Get-ChildItem $pkgs -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Item -Force -ErrorAction SilentlyContinue "$($_.FullName)\SystemAppData\Helium\UserClasses.dat"
    }
}
Write-Host "     [OK] Packaged-app view cache cleared." -ForegroundColor Green

# 7. Restart Explorer to apply changes immediately
if (-not $NoRestart) {
    Write-Host "  -> [5/5] Restarting File Explorer..." -ForegroundColor Yellow
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
        Start-Process explorer.exe
    }
    Write-Host "     [OK] File Explorer restarted." -ForegroundColor Green
}

Write-Host "`n+======================================================================+" -ForegroundColor Green
Write-Host "|   Success! 'Group By' is now permanently set to (None) globally!    |" -ForegroundColor Green
Write-Host "+======================================================================+`n" -ForegroundColor Green
Write-Host "Note: sign out/in (or reboot) once for the change to fully apply to" -ForegroundColor DarkGray
Write-Host "Open/Save dialogs in every app, not just File Explorer." -ForegroundColor DarkGray
