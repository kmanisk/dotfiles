

# Function to check if the script is running as Administrator
function Is-Admin {
    $identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Import Modules
Import-Module Microsoft.PowerShell.Utility
# Install-Module z -AllowClobber
# its different than the zoxide command 
function Add-ScoopBuckets {
    param (
        [hashtable]$buckets
    )
    
    $currentBuckets = scoop bucket list
    
    foreach ($bucket in $buckets.GetEnumerator()) {
        if ($currentBuckets.Name -notcontains $bucket.Key) {
            Write-Host "Adding bucket: $($bucket.Key)"
            if ($bucket.Value) {
                scoop bucket add $bucket.Key $bucket.Value
            }
            else {
                scoop bucket add $bucket.Key
            }
        }
        else {
            Write-Host "Bucket '$($bucket.Key)' already exists"
        }
    }
}

function Install-Scoop {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..."
        $installCommand = "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
        if (-not (Is-Admin)) {
            Write-Host "Installing Scoop"
            Write-Host $installCommand
        }
        else {
            Write-Host "Running Scoop installation with elevated permissions..."
            Invoke-Expression $installCommand
        }
    }
    else {
        Write-Host "==================================================================================================================================="
        Write-Host "Scoop is already installed."
        
        $bucketConfig = @{
            'extras'                 = ''
            'java'                   = ''
            'versions'               = ''
            'nerd-fonts'             = ''
            'volllly'                = 'https://github.com/volllly/scoop-bucket.git'
            'shemnei'                = 'https://github.com/Shemnei/scoop-bucket.git'
            'nonportable'            = 'https://github.com/Shemnei/scoop-bucket.git'
            'anderlli0053_DEV-tools' = 'https://github.com/anderlli0053/DEV-tools'

        }
        
        Add-ScoopBuckets -buckets $bucketConfig
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
    # Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
    # choco feature enable -n allowGlobalConfirmation
    # choco feature enable -n allowemptychecksums
    # choco feature enable -n checksumFiles
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


$configPath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\packages.json"
$path = Join-Path -Path $HOME -ChildPath ".local\share\chezmoi\AppData\Local\installer\packages.json"
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
    
    # Get list of installed packages with versions
    $installedPackages = choco list | ForEach-Object {
        if ($_ -match '^(\S+)\s+(\S+)') {
            @{
                Name    = $matches[1]
                Version = $matches[2]
            }
        }
    }

    # Separate packages into versioned and non-versioned
    $packagesToInstall = @()
    $versionedPackages = @()
    
    foreach ($package in $packages) {
        if ($package -match "^(.*) --version=(.*)$") {
            $packageName = $matches[1]
            $version = $matches[2]
            $installed = $installedPackages | Where-Object { $_.Name -eq $packageName }
            
            if (-not $installed) {
                $versionedPackages += @{Name = $packageName; Version = $version }
            }
            else {
                Write-Host "Package already installed: $packageName ($($installed.Version))"
            }
        }
        else {
            $installed = $installedPackages | Where-Object { $_.Name -eq $package }
            if (-not $installed) {
                $packagesToInstall += $package
            }
            else {
                Write-Host "Package already installed: $package ($($installed.Version))"
            }
        }
    }
    
    # Install non-versioned packages in batch if any
    if ($packagesToInstall.Count -gt 0) {
        Write-Host "Installing new packages: $($packagesToInstall -join ', ')"
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



# PermanentMachine Setup Function to call in the full setup section if chosen by the user
function Install-OSDLayout {
    # Set location to the source directory
    Set-Location -Path "$HOME\.local\share\chezmoi\appdata\local\OSD"

    # Define source directories
    $msiSource = "msi\Profiles"
    $rivaSource = "riva\Profiles"

    # Define target directories
    $msiTarget = "C:\Program Files (x86)\MSI Afterburner\Profiles"
    $rivaTarget = "C:\Program Files (x86)\RivaTuner Statistics Server\Profiles"

    # Check if profiles already exist
    if ((Test-Path "$msiTarget\*") -or (Test-Path "$rivaTarget\*")) {
        Write-Host "Profiles already exist. Skipping installation." -ForegroundColor Yellow
        return
    }

    # Check if source directories exist and have files
    $msiHasFiles = (Test-Path $msiSource) -and (@(Get-ChildItem -Path $msiSource -File -Recurse).Count -gt 0)
    $rivaHasFiles = (Test-Path $rivaSource) -and (@(Get-ChildItem -Path $rivaSource -File -Recurse).Count -gt 0)

    if (-not ($msiHasFiles -or $rivaHasFiles)) {
        Write-Host "No source profiles found in either directory" -ForegroundColor Yellow
        return
    }

    # Create target directories if they don't exist
    foreach ($dir in @($msiTarget, $rivaTarget)) {
        if (-not (Test-Path $dir)) {
            Write-Host "Creating directory at $dir"
            New-Item -Path $dir -ItemType Directory
        }
    }

    # Install profiles
    if ($msiHasFiles) { 
        Copy-Item -Path "$msiSource\*" -Destination $msiTarget -Recurse -Force 
        Write-Host "MSI profiles installed" -ForegroundColor Green
    }
    if ($rivaHasFiles) { 
        Copy-Item -Path "$rivaSource\*" -Destination $rivaTarget -Recurse -Force 
        Write-Host "RivaTuner profiles installed" -ForegroundColor Green
    }
}

function Move-FileSafely {
    param (
        [string]$sourcePath,
        [string]$destinationPath
    )

    if (Test-Path $sourcePath) {
        if (-not (Test-Path $destinationPath)) {
            Write-Host "Creating destination directory: $destinationPath"
            New-Item -Path $destinationPath -ItemType Directory -Force
        }

        Write-Host "Copying files from $sourcePath to $destinationPath"
        if (Test-Path -Path $sourcePath -PathType Leaf) {
            # Handle single file
            $fileName = Split-Path $sourcePath -Leaf
            $destFile = Join-Path $destinationPath $fileName
            if (Test-Path $destFile) {
                Write-Host "Updating existing file: $fileName"
            }
            else {
                Write-Host "Adding new file: $fileName"
            }
            Copy-Item -Path $sourcePath -Destination $destinationPath -Force
        }
        else {
            # Handle directory
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
        Write-Host "Files copied successfully"
    }
    else {
        Write-Host "Source path not found: $sourcePath"
    }
}

function Move-ConfigFolder {
    # ES Config
    $esSourcePath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\es"
    $esDestPath = "C:\es"
    
    # VSCodium Config
    $vscodiumSourcePath = Join-Path -Path $env:USERPROFILE -ChildPath ".local\share\chezmoi\AppData\Local\installer\vscodium\product.json"
    $vscodiumDestPath = "C:\Program Files\VSCodium\resources\app"

    Move-FileSafely -sourcePath $esSourcePath -destinationPath $esDestPath
    Move-FileSafely -sourcePath $vscodiumSourcePath -destinationPath $vscodiumDestPath
}

# function Install-VSCodeExtensions {
#     $vscodeInstalled = Get-Command code -ErrorAction SilentlyContinue
#     $vscodiumInstalled = Get-Command codium -ErrorAction SilentlyContinue
#
#     if (-not $vscodeInstalled) {
#         Write-Host "VSCode is not installed. Installing via Chocolatey..."
#         choco install vscode -y
#     }
#     else {
#         Write-Host "VSCode is already installed."
#     }
#
#     if (-not $vscodiumInstalled) {
#         Write-Host "VSCodium is not installed. Installing via Chocolatey..."
#         choco install vscodium -y
#     }
#     else {
#         Write-Host "VSCodium is already installed."
#     }
#
#     if ($vscodeInstalled -or $vscodiumInstalled) {
#         $extensionsFilePath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\vscode.txt"
#         
#         if (Test-Path $extensionsFilePath) {
#             $desiredExtensions = Get-Content -Path $extensionsFilePath
#             $vscodeExtensions = @()
#             $vscodiumExtensions = @()
#             
#             if ($vscodeInstalled) {
#                 $vscodeExtensions = & code --list-extensions
#                 $unmatchedVSCode = $vscodeExtensions | Where-Object { $desiredExtensions -notcontains $_ }
#                 if ($unmatchedVSCode) {
#                     Write-Host "`nUnmatched VSCode Extensions:" -ForegroundColor Yellow
#                     $unmatchedVSCode | ForEach-Object { Write-Host "  - $_" }
#                 }
#             }
#             
#             if ($vscodiumInstalled) {
#                 $vscodiumExtensions = & codium --list-extensions
#                 $unmatchedVSCodium = $vscodiumExtensions | Where-Object { $desiredExtensions -notcontains $_ }
#                 if ($unmatchedVSCodium) {
#                     Write-Host "`nUnmatched VSCodium Extensions:" -ForegroundColor Yellow
#                     $unmatchedVSCodium | ForEach-Object { Write-Host "  - $_" }
#                 }
#             }
#
#             $removeConfirmation = Read-Host "`nDo you want to remove unmatched extensions? (y/n)"
#             
#             # Rest of your existing code for handling VSCode and VSCodium extensions...
#             # [Previous implementation continues here]
#         }
#         else {
#             Write-Host "Extensions file not found at $extensionsFilePath."
#         }
#     }
#     else {
#         Write-Host "Neither VSCode nor VSCodium is installed. Cannot manage extensions."
#     }
# }
function Install-VSCodeExtensions {
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

    if ($vscodeInstalled -or $vscodiumInstalled) {
        $extensionsFilePath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\vscode.txt"
        
        if (Test-Path $extensionsFilePath) {
            $desiredExtensions = Get-Content -Path $extensionsFilePath
            $allExtensions = @()
            
            if ($vscodeInstalled) {
                $vscodeExtensions = & code --list-extensions
                $allExtensions += $vscodeExtensions
            }
            
            if ($vscodiumInstalled) {
                $vscodiumExtensions = & codium --list-extensions
                $allExtensions += $vscodiumExtensions
            }

            # Combine all unique extensions and update vscode.txt
            $uniqueExtensions = $allExtensions | Sort-Object -Unique
            $uniqueExtensions | Set-Content -Path $extensionsFilePath
            Write-Host "Updated vscode.txt with current extensions from both editors"
            
            # Display the current extension list
            Write-Host "`nCurrent Extensions:" -ForegroundColor Green
            $uniqueExtensions | ForEach-Object { Write-Host "  - $_" }
            
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
}
function disable-Clipboard {
    
    # PowerShell script to disable the Clipboard User Service (cbdhsvc)
    # disables services

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

    # Define the registry path and value
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $valueName = "AllowClipboardHistory"
    $valueData = 0

    # Check if the registry path exists; if not, create it
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the registry value to disable Clipboard History
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord

    # Output the result
    Write-Output "Clipboard History has been disabled."

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

function MLWapp {
    
    $installerDir = Join-Path $HOME "AppData\Local\installer"
    $mlwappInstaller = Get-ChildItem -Path $installerDir -Filter "MLWapp*.exe" | Select-Object -First 1
    $mlwappInstalled = Test-Path "C:\Program Files\MLWapp\MLWapp.exe"

    if (-not $mlwappInstalled) {
        if ($mlwappInstaller) {
            Write-Host "Installing MLWapp..."
            Start-Process -FilePath $mlwappInstaller.FullName -ArgumentList "/S" -NoNewWindow -Wait
        }
        else {
            Write-Host "MLWapp installer not found in $installerDir." -ForegroundColor Red
        }
    }
    else {
        Write-Host "MLWapp is already installed."
    }
}
function spot {
    $spotifyPath = Join-Path $HOME "AppData\Roaming\Spotify\spotify.exe"
    if (-not (Test-Path $spotifyPath)) {
        $confirmation = Read-Host "Do you want to install Spotify? (y/n)"
        
        if ($confirmation -eq 'y') {
            Write-Host "Installing Spotify..."
            Invoke-Expression "& { $(Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -new_theme"
        }
        else {
            Write-Host "Operation Skipped" -ForegroundColor DarkMagenta
        }
    }
    else {
        Write-Host "Spotify is already installed at $spotifyPath" -ForegroundColor Green
    }
}

function install-Curls {
    # Check if already installed
    $gm320Path = "C:\Program Files (x86)\GM320 RGB"
    if (Test-Path $gm320Path) {
        Write-Host "GM320 RGB is already installed at $gm320Path"
        return
    }

    # Check if aria2c is installed
    if (-not (Get-Command aria2c -ErrorAction SilentlyContinue)) {
        Write-Host "Installing aria2c via Scoop..."
        scoop install aria2
    }

    # Rest of your existing code...
    $documentsPath = [Environment]::GetFolderPath("MyDocuments")
    $curlsFolder = Join-Path $documentsPath "curls"
    $zipPath = Join-Path $curlsFolder "mouse.zip"
    
    if (-not (Test-Path $curlsFolder)) {
        Write-Host "Creating curls directory at $curlsFolder..."
        New-Item -Path $curlsFolder -ItemType Directory | Out-Null
    }
    
    Set-Location $curlsFolder
    
    if (-not (Test-Path $zipPath)) {
        Write-Host "Downloading mouse.zip using aria2c..."
        $url = "https://drive.google.com/uc?export=download&id=1pa2ryQyBDNiS4aOOYjiOqweFybOrtO3f"
        $aria2Path = "aria2c"
        & $aria2Path --dir=$curlsFolder --out="mouse.zip" $url
    }
    
    Write-Host "Extracting files..."
    $sevenZipPath = "7z"
    & $sevenZipPath x $zipPath -o$curlsFolder | Out-Null
    
    Write-Host "Searching for .exe or .msi files..."
    $executables = Get-ChildItem -Path $curlsFolder -Recurse -File | Where-Object { $_.Extension -in @(".exe", ".msi") }
    if ($executables) {
        foreach ($file in $executables) {
            Write-Host "Running $($file.Name)..."
            Start-Process -FilePath $file.FullName -NoNewWindow -Wait
        }
    }
    else {
        Write-Host "No .exe or .msi files found!"
    }
}


Install-Scoop
Write-Host "=============================================================================================================================================="
Install-Chocolatey
Write-Host "=============================================================================================================================================="
Install-Winget
Write-Host "=============================================================================================================================================="
function Set-PermanentMachine {
    Write-Host "Disabling Clipboard"
    disable-Clipboard
    Write-Host "=============================================================================================================================================="
    Write-Host "OSD" -ForegroundColor Green
    Install-OSDLayout
    Write-Host "=============================================================================================================================================="
    spot
    Write-Host "=============================================================================================================================================="
    Write-Host "MLwapp install"
    MLWapp
    Write-Host "=============================================================================================================================================="
    Write-Host "Move config folder"
    Move-ConfigFolder
    Write-Host "=============================================================================================================================================="
    Install-VSCodeExtensions
    Write-Host "=============================================================================================================================================="
    Set-Wsl
    Write-Host "=============================================================================================================================================="
    ClinkSetup
    Write-Host "=============================================================================================================================================="
    install-Curls

}

# Prompt the user for installation type
$choice = Read-Host "Choose installation type (mini/full)"
switch ($choice.ToLower()) {
    "mini" {
        # Install Scoop packages
        # old method get-filehash issue
        # Install-ScoopPackages -packages $config.scoop.mini
        # Call scoopmini.py
        python "$HOME\.local\share\chezmoi\AppData\Local\installer\scoopmini.py"
        
        Write-Host "=============================================================================================================================================="
        # Install Winget packages
        Install-WingetPackages -packages $config.winget.mini

        Write-Host "=============================================================================================================================================="
        # Install Chocolatey packages
        Install-ChocoPackages -packages $config.choco.mini

        Write-Host "=============================================================================================================================================="
    }
    "full" {
        # Install full packages
        # Install Scoop packages
        # Install-ScoopPackages -packages $config.scoop.full
        Write-Host "=============================================================================================================================================="
        # Call scoopfull.py
        python "$HOME\.local\share\chezmoi\AppData\Local\installer\scoopfull.py"
        # Install Winget packages
        Write-Host "=============================================================================================================================================="
        Install-WingetPackages -packages $config.winget.full
        Write-Host "=============================================================================================================================================="
        # Install Chocolatey packages
        Install-ChocoPackages -packages $config.choco.full
        #Permanent Machine Setup
        Write-Host "=============================================================================================================================================="
        Set-PermanentMachine
    }
}

Write-Host "Installation completed!" -ForegroundColor Green


# Function to pin a Chocolatey package if it is installed
# after everything pin packages that are stable with a speicifc versions 
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

Write-Host "============================================================================================================================"
# Call the function to pin zoxide
Pin-ChocoPackage -packageName "zoxide"
Write-Host "==========================================================================================================================="
Pin-ChocoPackage -packageName "autohotkey"
Write-Host "============================================================================================================================="
Pin-WingetPackage -packageId "AutoHotkey.AutoHotkey"
Write-Host "=============================================================================================================================="
