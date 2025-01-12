

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

function Install-ChocoPackages {
    param (
        [string[]]$packages
    )
    
    # Get list of installed packages
    $installedPackages = choco list | ForEach-Object { ($_ -split '\|')[0] }
    
    # Separate packages into versioned and non-versioned
    $packagesToInstall = @()
    $versionedPackages = @()
    
    foreach ($package in $packages) {
        if ($package -match "^(.*) --version=(.*)$") {
            $packageName = $matches[1]
            $version = $matches[2]
            if ($installedPackages -notcontains $packageName) {
                $versionedPackages += @{Name = $packageName; Version = $version }
            }
        }
        elseif ($installedPackages -notcontains $package) {
            $packagesToInstall += $package
        }
    }
    
    # Batch install non-versioned packages
    if ($packagesToInstall.Count -gt 0) {
        Write-Host "Installing packages: $($packagesToInstall -join ', ')"
        choco install $packagesToInstall -y
    }
    
    # Install versioned packages individually
    foreach ($pkg in $versionedPackages) {
        Write-Host "Installing $($pkg.Name) version $($pkg.Version)"
        choco install $pkg.Name --version=$($pkg.Version) -y
    }
}
function Install-WingetPackages {
    param (
        [string[]]$packages
    )

    # Get list of installed packages
    $installedPackages = winget list

    foreach ($package in $packages) {
        # Escape special characters in package name for regex pattern
        $escapedPackage = [regex]::Escape($package)
        
        # Check if package is already installed
        if ($installedPackages | Select-String -Pattern $escapedPackage) {
            Write-Host "$package is already installed. Skipping..."
            continue
        }

        try {
            Write-Host "Installing package: $package"
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
    $destinationPath = "C:\es"

    if (Test-Path $sourcePath) {
        if (Test-Path $destinationPath) {
            Write-Host "Destination folder exists at $destinationPath. Syncing contents..."
            Get-ChildItem -Path $sourcePath | ForEach-Object {
                $destItem = Join-Path $destinationPath $_.Name
                if (Test-Path $destItem) {
                    Write-Host "Updating existing item: $($_.Name)"
                }
                else {
                    Write-Host "Adding new item: $($_.Name)"
                }
                Copy-Item -Path $_.FullName -Destination $destinationPath -Force -Recurse
            }
        }
        else {
            Write-Host "Creating and populating $destinationPath..."
            New-Item -Path $destinationPath -ItemType Directory
            Get-ChildItem -Path $sourcePath | Copy-Item -Destination $destinationPath -Force -Recurse
        }
        Write-Host "Config folder sync completed successfully"
    }
    else {
        Write-Host "Source folder not found at $sourcePath"
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

    # Proceed to manage extensions only if at least one editor is installed
    if ($vscodeInstalled -or $vscodiumInstalled) {
        $extensionsFilePath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\vscode.txt"

        if (Test-Path $extensionsFilePath) {
            # Read desired extensions from file
            $desiredExtensions = Get-Content -Path $extensionsFilePath

            # Get currently installed extensions
            $vscodeExtensions = @()
            $vscodiumExtensions = @()
            
            if ($vscodeInstalled) {
                $vscodeExtensions = & code --list-extensions
            }
            if ($vscodiumInstalled) {
                $vscodiumExtensions = & codium --list-extensions
            }

            # Handle VSCode Extensions
            if ($vscodeInstalled) {
                # Install missing extensions
                foreach ($extension in $desiredExtensions) {
                    if ($vscodeExtensions -notcontains $extension) {
                        Write-Host "Installing VSCode extension: $extension"
                        & code --install-extension $extension
                    }
                }
                
                # Remove undesired extensions
                foreach ($installed in $vscodeExtensions) {
                    if ($desiredExtensions -notcontains $installed) {
                        Write-Host "Removing VSCode extension: $installed"
                        & code --uninstall-extension $installed
                    }
                }
            }

            # Handle VSCodium Extensions
            if ($vscodiumInstalled) {
                # Install missing extensions
                foreach ($extension in $desiredExtensions) {
                    if ($vscodiumExtensions -notcontains $extension) {
                        Write-Host "Installing VSCodium extension: $extension"
                        & codium --install-extension $extension
                    }
                }
                
                # Remove undesired extensions
                foreach ($installed in $vscodiumExtensions) {
                    if ($desiredExtensions -notcontains $installed) {
                        Write-Host "Removing VSCodium extension: $installed"
                        & codium --uninstall-extension $installed
                    }
                }
            }

            Write-Host "Extensions synchronization completed successfully."
        }
        else {
            Write-Host "Extensions file not found at $extensionsFilePath."
        }
    }
    else {
        Write-Host "Neither VSCode nor VSCodium is installed. Cannot manage extensions."
    }
}


function Set-Wsl {
    # Check if WSL is already installed
    $wslCheck = wsl --status 2>&1
    if ($wslCheck -notlike "*WSL is not installed*") {
        Write-Host "WSL is already installed."
        Write-Host "Current WSL Status:"
        wsl --status
        return
    }

    # Step 1: Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10 -or ($osVersion.Major -eq 10 -and $osVersion.Build -lt 19041)) {
        Write-Host "You must be running Windows 10 version 2004 (Build 19041) or higher, or Windows 11 to use WSL."
        return
    }
    Write-Host "Windows version is compatible with WSL."

    # Proceed with WSL installation
    Write-Host "Enabling Windows Subsystem for Linux and Virtual Machine Platform..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    Write-Host "Setting WSL 2 as the default version..."
    wsl --set-default-version 2

    # Write-Host "Installing Debian as the default Linux distribution..."
    # wsl --install -d Debian

    # Write-Host "Available Linux distributions:"
    # wsl --list --online
}
function disable-Clipboard {
    
    # PowerShell script to disable the Clipboard User Service (cbdhsvc)

    # Define the registry path and value name
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\cbdhsvc"
    $valueName = "Start"
    $disabledValue = 4
    # Check if the registry path exists
    if (Test-Path $registryPath) {
        # Set the Start value to 4 (disabled)
        Set-ItemProperty -Path $registryPath -Name $valueName -Value $disabledValue -Force
        Write-Host "The cbdhsvc service has been disabled successfully."
    }
    else {
        Write-Host "The registry path does not exist. The service might not be available on this system."
    }

}

function Set-PermanentMachine {
    disable-Clipboard
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

function Pin-WingetPackage {
    param (
        [string]$packageId
    )
    
    # Check if package is installed using winget list
    $installedPackages = winget list | Select-String -Pattern $packageId
    
    if ($installedPackages) {
        Write-Host "$packageId is installed. Pinning the package..."
        winget pin add --id $packageId
        Write-Host "$packageId has been pinned."
    }
    else {
        Write-Host "$packageId is not installed. Skipping pinning."
    }
}

# Call the function to pin zoxide
Pin-ChocoPackage -packageName "zoxide"
Pin-ChocoPackage -packageName "autohotkey"
Pin-WingetPackage -packageId "AutoHotkey.AutoHotkey"