$modifiedFiles = chezmoi status | Where-Object { $_ -match 'MM' }
foreach ($file in $modifiedFiles) {
    $filePath = $file.Trim() -replace '^MM\s*', ''
    $absolutePath = Join-Path $env:USERPROFILE $filePath
    Write-Host $absolutePath
    chezmoi add $absolutePath
}
