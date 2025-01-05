
# Import Modules
Import-Module Microsoft.PowerShell.Utility

# Function to install Scoop
function Install-Scoop {
    # Check if Scoop is installed
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..."

        # Check if ExecutionPolicy allows script execution
        $currentPolicy = Get-ExecutionPolicy
        if ($currentPolicy -ne 'RemoteSigned') {
            Write-Host "Setting ExecutionPolicy to RemoteSigned"
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        }

        # Download and install Scoop
        try {
            Invoke-Expression (New-Object Net.WebClient).DownloadString('https://get.scoop.sh')
            Write-Host "Scoop installation successful."
        }
        catch {
            Write-Host "Failed to install Scoop: $_"
        }
    }
    else {
        Write-Host "Scoop is already installed."
    }
}

# Define Scoop buckets (excluding main and extras)
$scoopBuckets = @(
    # @{ Name = "extras"; URL = "https://github.com/ScoopInstaller/Extras.git" },
    @{ Name = "versions"; URL = "https://github.com/ScoopInstaller/Versions.git" },
    @{ Name = "nerd-fonts"; URL = "https://github.com/matthewjberger/scoop-nerd-fonts.git" },
    @{ Name = "shemnei"; URL = "https://github.com/Shemnei/scoop-bucket.git" },
    @{ Name = "volllly"; URL = "https://github.com/volllly/scoop-bucket.git" }
)

# Check and add buckets
foreach ($bucket in $scoopBuckets) {
    $bucketInfo = scoop bucket list | Where-Object { $_ -match $bucket.Name }

    if (-not $bucketInfo) {
        # If bucket is not listed, add it
        Write-Host "Adding Scoop bucket: $($bucket.Name)"
        scoop bucket add $($bucket.Name) $($bucket.URL)
    }
    else {
        # Extract manifest count
        $manifestCount = ($bucketInfo -split '\s+')[-1]
        if ([int]$manifestCount -eq 0) {
            # If manifest count is 0, re-add the bucket
            Write-Host "The '$($bucket.Name)' bucket has 0 manifests. Re-adding..."
            scoop bucket rm $($bucket.Name)
            scoop bucket add $($bucket.Name) $($bucket.URL)
        }
        else {
            Write-Host "The '$($bucket.Name)' bucket already exists with $manifestCount manifests."
        }
    }
}
scoop bucket add extras




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
        [string[]]$packages
    )
    foreach ($package in $packages) {
        # Install the package using Scoop
        scoop install $package 
    }
}

# Function to install Chocolatey packages
function Install-ChocoPackages {
    param (
        [string[]]$packages
    )
    foreach ($package in $packages) {
        # Install the package using Chocolatey
        choco install $package -y
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
function Set-PermanentMachine {
    Write-Host "Installing Spotify..."
    try {
        Invoke-Expression "& { $(Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -new_theme"
    }
    catch {
        Write-Host "Failed to install Spotify. Error: $_" -ForegroundColor Red
        return
    }
        
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

    Move-ConfigFolder
    Install-VSCodeExtensions
}

$userInput = Read-Host "Do you want to install Spotify? (y/n)"

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
