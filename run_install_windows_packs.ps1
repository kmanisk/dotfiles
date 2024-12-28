function osd-layout {
    # Set location to the source directory
    Set-Location -Path "$HOME\.local\share\chezmoi\appdata\local\OSD"

    # Define source directories
    $msiSource = "msi\Profiles"
    $rivaSource = "riva\Profiles"

    # Define target directories
    $msiTarget = "C:\Program Files (x86)\MSI Afterburner\Profiles"
    $rivaTarget = "C:\Program Files (x86)\RivaTuner Statistics Server\Profiles"

    # Ensure the target directories exist, create them if they don't
    if (-not (Test-Path $msiTarget)) {
        Write-Host "Creating MSI Afterburner directory at $msiTarget"
        New-Item -Path $msiTarget -ItemType Directory
    }
    if (-not (Test-Path $rivaTarget)) {
        Write-Host "Creating RivaTuner directory at $rivaTarget"
        New-Item -Path $rivaTarget -ItemType Directory
    }

    # Copy all files and subdirectories from the source directories to the target directories
    Copy-Item -Path "$msiSource\*" -Destination $msiTarget -Recurse -Force
    Copy-Item -Path "$rivaSource\*" -Destination $rivaTarget -Recurse -Force

    Write-Host "Files copied successfully to the target locations."
}
# osd-layout


function startup () {
    $startupFolder = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
    
    Write-Host "Starting the startup function..."
    Write-Host "Determining the Startup folder path: $startupFolder"
    
    # Call the function to copy AutoHotkey scripts
    Write-Host "Copying AutoHotkey scripts to the Startup folder..."
    copy-autohotkey-scripts
    
    Write-Host "Startup function completed."
}
startup

Write-Host "run_install_windows_packs.ps1 ran" -ForegroundColor Green