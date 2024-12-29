function Install-OSDLayout {
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
Install-OSDLayout
## Path to the installer file
$installerPath = "C:\Users\Manisk\AppData\Local\installer\MLWapp2.6.x64.exe"

# Check if MLWapp is already installed
$mlwappInstalled = Get-Command "C:\Program Files\MLWapp\MLWapp.exe" -ErrorAction SilentlyContinue

if (-not $mlwappInstalled) {
    # Run the installer if MLWapp is not installed
    Start-Process -FilePath $installerPath -ArgumentList "/S" -NoNewWindow -Wait
}
else {
    Write-Host "MLWapp is already installed."
}


function Install-Spotify {
    $userInput = Read-Host "Do you want to install Spotify? (y/n)"
    
    if ($userInput -eq 'y') {
        Write-Host "Installing Spotify..."
        Invoke-Expression "& { $(Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -new_theme"
    }
    elseif ($userInput -eq 'n') {
        Write-Host "Spotify installation skipped."
    }
    else {
        Write-Host "Invalid input. Please enter 'y' or 'n'."
    }
}

Install-Spotify
function Move-ConfigFolder {
    $sourcePath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\es"
    $destinationPath = "C:\es"

    # Check if the source folder exists
    if (Test-Path $sourcePath) {
        # Create the destination directory if it doesn't exist
        if (-not (Test-Path $destinationPath)) {
            New-Item -Path $destinationPath -ItemType Directory
            Write-Host "Created destination directory at $destinationPath"
        }

        # Move the folder
        Move-Item -Path $sourcePath -Destination $destinationPath -Force
        Write-Host "Moved folder from $sourcePath to $destinationPath"
    }
    else {
        Write-Host "Source folder $sourcePath does not exist."
    }
}

# Call the function to move the config folder
Move-ConfigFolder
function Move-ScriptToDesktop {
    $scriptPath = $MyInvocation.MyCommand.Path
    $desktopPath = Join-Path -Path $env:USERPROFILE -ChildPath "Desktop"
    $destinationPath = Join-Path -Path $desktopPath -ChildPath "run_install_windows_packs.ps1"

    # Move the script to the Desktop
    Move-Item -Path $scriptPath -Destination $destinationPath -Force
    Write-Host "Moved script to $destinationPath"
}

# Call the function to move the script to the Desktop
Move-ScriptToDesktop
