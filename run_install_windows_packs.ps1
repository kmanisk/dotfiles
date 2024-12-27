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
osd-layout

function copy-autohotkey-scripts {
    $sourcePath = "$HOME\.local\share\chezmoi\appdata\local\autohotkey"
    $startupFolder = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
    $ahkPath = "C:\Program Files\AutoHotkey\AutoHotkey.exe"  # Update the path if AutoHotkey is installed elsewhere

    # Ensure the source directory exists
    if (Test-Path $sourcePath) {
        Write-Host "Running AutoHotkey scripts from $sourcePath..."
        
        # Get all .ahk files in the source directory and run them
        $scripts = Get-ChildItem -Path $sourcePath -Filter *.ahk
        foreach ($script in $scripts) {
            Write-Host "Running script: $($script.FullName)"
            # Run each script using AutoHotkey
            Start-Process $ahkPath -ArgumentList $script.FullName
        }

        Write-Host "Copying AutoHotkey scripts from $sourcePath to $startupFolder..."
        Copy-Item -Path "$sourcePath\*" -Destination $startupFolder -Recurse -Force
        Write-Host "AutoHotkey scripts copied successfully to the Startup folder."
    }
    else {
        Write-Host "Source directory $sourcePath does not exist."
    }
}

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
function prompt-user {
    $response = Read-Host "Do you want to proceed terminal and powershell 7? (yes/no)"
    if ($response -eq "yes") {
        Write-Host "User chose to proceed with the task."
        choco install powershell-core microsoft-windows-terminal
        copy-autohotkey-scripts
    }
    else {
        Write-Host "User chose not to proceed with the task."
    }
}
prompt-user


Write-Host "run_install_windows_packs.ps1 ran hhere old one" -ForegroundColor Green