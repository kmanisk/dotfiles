

# Function to check if the script is running as Administrator
function Is-Admin {
    $identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Import Modules
Import-Module Microsoft.PowerShell.Utility
# Install-Module z -AllowClobber
# its different than the zoxide command 


#  Function to check if a Scoop bucket exists
function Check-And-AddBucket {
    param (
        [string]$bucketName,
        [string]$bucketUrl
    )

    # Get the list of existing buckets and extract just the names
    $existingBuckets = scoop bucket list | ForEach-Object { 
        if ($_ -match '^\s*(\S+)') {
            $matches[1]  # Capture the first non-whitespace sequence
        }
    } | Where-Object { $_ -ne $null }  # Filter out any null values

    # Debugging output to check existing buckets
    Write-Host "Existing Buckets: $existingBuckets"

    # Check if the bucket is already in the list
    if ($existingBuckets -notcontains $bucketName) {
        Write-Host "Adding Scoop bucket: $bucketName"
        scoop bucket add $bucketName $bucketUrl
    }
    else {
        Write-Host "Scoop bucket '$bucketName' already exists."
    }
}


# Function to install Scoop
function Install-Scoop {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..."
        if (-not (Is-Admin)) {
            Write-Host "Installing Scoop"
            Write-Host "iex ""& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"""
        }
        else {
            Write-Host "Running Scoop installation with elevated permissions..."
            Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
        }
    }
    else {
        Write-Host "Scoop is already installed."
        # Check and add buckets
        Check-And-AddBucket -bucketName "extras" -bucketUrl ""
        Check-And-AddBucket -bucketName "java" -bucketUrl ""
        Check-And-AddBucket -bucketName "versions" -bucketUrl ""
        Check-And-AddBucket -bucketName "nerd-fonts" -bucketUrl ""
        Check-And-AddBucket -bucketName "volllly" -bucketUrl "https://github.com/volllly/scoop-bucket.git"
        Check-And-AddBucket -bucketName "shemnei" -bucketUrl "https://github.com/Shemnei/scoop-bucket.git"
    }
}
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey is not installed. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-WebRequest https://community.chocolatey.org/install.ps1 -OutFile install.ps1
        .\install.ps1
        Remove-Item -Force install.ps1
        [System.Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\ProgramData\chocolatey\bin', 'Machine')
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    }
    else {
        Write-Host "Chocolatey is already installed."
    }

    # Configure Chocolatey settings
    Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
    choco feature enable -n allowGlobalConfirmation
    choco feature enable -n allowemptychecksums
    choco feature enable -n checksumFiles
}
# Function to install Winget
function Install-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Winget..."
        Install-Script winget-install -Force
        winget-install -Force
    }
    else {
        Write-Host "Winget is already installed."
    }
}

Install-Scoop
Install-Chocolatey
Install-Winget

# Load the JSON configuration from the user's home directory
$configPath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\packages.json"
# Write-Host "Config Path : $configPath"
$config = Get-Content -Path $configPath | ConvertFrom-Json
# Function to install Scoop packages
function Install-ScoopPackages {
    param (
        [string[]]$packages  # Accept an array of package names
    )

    foreach ($package in $packages) {
        Write-Host "Installing Scoop package: $package"
        scoop install $package 
        Write-Host ""
    }
}

# Function to install Chocolatey packages
function Install-ChocoPackages {
    param (
        [string[]]$packages
    )
    foreach ($package in $packages) {
        # Check if the package has a version specified
        if ($package -match "^(.*) --version=(.*)$") {
            $packageName = $matches[1]
            $version = $matches[2]
            Write-Host "Installing Chocolatey package: $packageName with version $version"
            choco install $packageName --version=$version -y
        }
        else {
            Write-Host "Installing Chocolatey package: $package"
            choco install $package -y
        }
    }
}
# Function to install Winget packages with source flag
function Install-WingetPackages {
    param (
        [string[]]$packages
    )
    foreach ($package in $packages) {
        try {
            # Install the package using Winget without the -y flag
            Write-Host "winget install packages"
            winget install --id $package --source winget
        }
        catch {
            Write-Host "Failed to install package: $package. Error: $_"
        }
    }
}


# Prompt the user for installation type
$choice = Read-Host "Choose installation type (mini/full)"
switch ($choice.ToLower()) {
    "mini" {
        # Install mini packages
        # Install Scoop packages
        Install-ScoopPackages -packages $config.scoop.mini
        # Install Winget packages
        Install-WingetPackages -packages $config.winget.mini
        # Install Chocolatey packages
        Install-ChocoPackages -packages $config.choco.mini
    }
    "full" {
        # Install full packages
        # Install Scoop packages
        Install-ScoopPackages -packages $config.scoop.full
        # Install Winget packages
        Install-WingetPackages -packages $config.winget.full
        # Install Chocolatey packages
        Install-ChocoPackages -packages $config.choco.full
    }
    default {
        Write-Host "Invalid choice. Exiting..."
        exit
    }
}

Write-Host "Installation completed!"



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



function Move-ConfigFolder {
    $sourcePath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\es"
    $destinationPath = "C:\es"  # Set the destination to C:\es

    if (Test-Path $sourcePath) {
        if (-not (Test-Path $destinationPath)) {
            New-Item -Path $destinationPath -ItemType Directory
            Write-Host "Created destination directory at $destinationPath"
        }

        Move-Item -Path $sourcePath -Destination $destinationPath -Force
        Write-Host "Moved folder from $sourcePath to $destinationPath"
    }
    else {
        Write-Host "Source folder $sourcePath does not exist."
    }
}


function Install-VSCodeExtensions {
    # Check if VSCode and VSCodium are installed
    $vscodeInstalled = Get-Command code -ErrorAction SilentlyContinue
    $vscodiumInstalled = Get-Command codium -ErrorAction SilentlyContinue

    if (-not $vscodeInstalled) {
        Write-Host "VSCode is not installed. Installing via Chocolatey..."
        choco install vscode -y
    }
    else {
        Write-Host "VSCode is already installed."
    }

    if (-not $vscodiumInstalled) {
        Write-Host "VSCodium is not installed. Installing via Chocolatey..."
        choco install vscodium -y
    }
    else {
        Write-Host "VSCodium is already installed."
    }

    # Proceed to install extensions only if at least one of them is installed
    if ($vscodeInstalled -or $vscodiumInstalled) {
        $extensionsFilePath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\vscode.txt"

        if (Test-Path $extensionsFilePath) {
            $extensions = Get-Content -Path $extensionsFilePath
            foreach ($extension in $extensions) {
                # Install the extension for VSCode
                if ($vscodeInstalled) {
                    Write-Host "Installing VSCode extension: $extension"
                    & code --install-extension $extension
                }

                # Install the extension for VSCodium
                if ($vscodiumInstalled) {
                    Write-Host "Installing VSCodium extension: $extension"
                    & codium --install-extension $extension
                }
            }
        }
        else {
            Write-Host "Extensions file not found at $extensionsFilePath."
        }
    }
    else {
        Write-Host "Neither VSCode nor VSCodium is installed. Cannot install extensions."
    }
}



function Set-Wsl {
    # Step 1: Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10 -or ($osVersion.Major -eq 10 -and $osVersion.Build -lt 19041)) {
        Write-Host "You must be running Windows 10 version 2004 (Build 19041) or higher, or Windows 11 to use WSL."
        return
    }
    Write-Host "Windows version is compatible with WSL."

    # Step 2: Enable WSL and Virtual Machine Platform
    Write-Host "Enabling Windows Subsystem for Linux and Virtual Machine Platform..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    # Step 3: Restart the machine to complete the WSL installation
    Write-Host "Please restart your machine to complete the installation of WSL."

    # Step 4: Set WSL 2 as the default version
    Write-Host "Setting WSL 2 as the default version..."
    wsl --set-default-version 2

    # Step 5: Install Debian
    Write-Host "Installing Debian as the default Linux distribution..."
    wsl --install -d Debian

    # Step 6: List available distributions
    Write-Host "Available Linux distributions:"
    wsl --list --online
}

function Set-PermanentMachine {
    Write-Host "Installing Spotify..."
    #try {
    #    Invoke-Expression "& { $(Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -new_theme"
    #}
    #catch {
    #    Write-Host "Failed to install Spotify. Error: $_" -ForegroundColor Red
    #    return
    #}
        
    $installerPath = "C:\Users\Manisk\AppData\Local\installer\executable_MLWapp2.6.x64.exe"
    $mlwappInstalled = Test-Path "C:\Program Files\MLWapp\MLWapp.exe"

    if (-not $mlwappInstalled) {
        if (Test-Path $installerPath) {
            Write-Host "Installing MLWapp..."
            Start-Process -FilePath $installerPath -ArgumentList "/S" -NoNewWindow -Wait
        }
        else {
            Write-Host "MLWapp installer not found at $installerPath." -ForegroundColor Red
        }
    }
    else {
        Write-Host "MLWapp is already installed."
    }

    #function calls
    Move-ConfigFolder
    Install-VSCodeExtensions
    Set-Wsl
}

$userInput = Read-Host "Set per machine (Y/N)?"

if ($userInput -eq 'y') {
    Set-PermanentMachine
}
else {
    Write-Host "Operation skipped."
}


function ClinkSetup {
    $clinkPath = "C:\Program Files (x86)\clink"

    # Check if the path is already in the PATH environment variable
    if ($env:Path -notlike "*$clinkPath*") {
        Write-Host "Adding Clink path to the system PATH variable..."
        
        # Add the Clink path to the system PATH variable
        [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$clinkPath", [System.EnvironmentVariableTarget]::Machine)

        Write-Host "Clink path added successfully."
    }
    else {
        Write-Host "Clink path is already in the system PATH variable."
    }
}

# Call the Clink-setup function
ClinkSetup

# Function to pin a Chocolatey package if it is installed
function Pin-ChocoPackage {
    param (
        [string]$packageName
    )

    # Check if the package is installed using choco list
    $installedPackages = choco list | Select-String -Pattern $packageName

    if ($installedPackages) {
        Write-Host "$packageName is installed. Pinning the package..."
        choco pin add -n $packageName
        Write-Host "$packageName has been pinned."
    }
    else {
        Write-Host "$packageName is not installed. Skipping pinning."
    }
}

# Call the function to pin zoxide
Pin-ChocoPackage -packageName "zoxide"
Pin-ChocoPackage -packageName "autohotkey"
