$RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters"
$ValueName = "CrashOnCtrlScroll"
$ValueData = 1

# Check if the registry path exists
if (!(Test-Path $RegistryPath)) {
    Write-Host "Registry path does not exist. Creating it..."
    New-Item -Path $RegistryPath -Force | Out-Null
}

# Check if the value exists
$ExistingValue = Get-ItemProperty -Path $RegistryPath -Name $ValueName -ErrorAction SilentlyContinue

if ($ExistingValue) {
    # If value exists, update it
    Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $ValueData
    Write-Host "Updated '$ValueName' to $ValueData"
} else {
    # If value does not exist, create it
    New-ItemProperty -Path $RegistryPath -Name $ValueName -PropertyType DWORD -Value $ValueData -Force
    Write-Host "Created '$ValueName' with value $ValueData"
}

Write-Host "Operation completed successfully."
