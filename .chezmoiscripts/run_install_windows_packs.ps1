
function pipInstallEssential {
    Write-Host "Installing essential Python packages..."
    
    # List of essential packages
    $packages = @(
        "gdown"
    )

    # Check if gdown is already installed
    if (-not (Get-Command gdown -ErrorAction SilentlyContinue)) {
        # Check if pip is installed
        if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
            Write-Host "Installing pip..."
            python -m ensurepip --upgrade
        }

        # Upgrade pip itself
        python -m pip install --upgrade pip

        # Install each package
        foreach ($package in $packages) {
            Write-Host "Installing $package..."
            pip install $package
        }
    }
    else {
        Write-Host "gdown is already installed, skipping Python package installation"
    }

    Write-Host "Essential Python packages installation completed"
}

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
        Write-Host "======================================================================================================================="
        Write-Host "Scoop is already installed."
        
        $bucketConfig = @{
            'main'                  = 'https://github.com/ScoopInstaller/Main'
            'extras'                = 'https://github.com/ScoopInstaller/Extras'
            'java'                  = 'https://github.com/ScoopInstaller/Java'
            'versions'              = 'https://github.com/ScoopInstaller/Versions'
            'nerd-fonts'            = 'https://github.com/ScoopInstaller/scoop-nerd-fonts'
            'games'                 = 'https://github.com/Calinou/scoop-games'
            'volllly'               = 'https://github.com/volllly/scoop-bucket.git'
            'shemnei'               = 'https://github.com/Shemnei/scoop-bucket.git'
            'nonportable'           = 'https://github.com/Shemnei/scoop-bucket.git'
            'kkzzhizhou_scoop-apps' = 'https://github.com/kkzzhizhou/scoop-apps'
            'chawyehsu_dorado'      = 'https://github.com/chawyehsu/dorado'
            # 'anderlli0053_DEV-tools' = 'https://github.com/anderlli0053/DEV-tools'

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

function Add-AdbToPath {
    $adbPath = Join-Path $HOME "AppData\Local\installer\adbdrivers"
    
    # More specific path matching using regex
    if ($env:Path -notmatch [regex]::Escape("installer\adbdrivers")) {
        Write-Host "Adding ADB path to the system PATH variable..."
        
        # Add the ADB path to the system PATH variable
        [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$adbPath", [System.EnvironmentVariableTarget]::Machine)
        
        Write-Host "ADB path added successfully."
    }
    else {
        Write-Host "ADB path is already in the system PATH variable."
    }
}


# PermanentMachine Setup Function to call in the full setup section if chosen by the user
#function Install-OSDLayout {
#    $rtssProfilePath = "$HOME\scoop\persist\rtss\Profiles"
#    $msiProfilePath = "$HOME\scoop\persist\msiafterburner\Profiles"
#
#    if (-not (Test-Path "$rtssProfilePath\*") -or -not (Test-Path "$msiProfilePath\*")) {
#        Write-Host "No profiles found. Please install MSI Afterburner and RivaTuner through Scoop and use Chezmoi to manage the profiles." -ForegroundColor Yellow
#        return
#    }
#
#    Write-Host "Profiles are already managed by Scoop and Chezmoi" -ForegroundColor Green
#}

function Install-OSDLayout {
    $msiExecutablePath = "$HOME\scoop\apps\msiafterburner\current\msiafterburner.exe"
    $rtssExecutablePath = "$HOME\scoop\apps\rtss\current\RTSS.exe"
    $startupFolder = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

    # Check if MSI Afterburner and RTSS executables exist
    if (-not (Test-Path $msiExecutablePath) -or -not (Test-Path $rtssExecutablePath)) {
        Write-Host "MSI Afterburner or RTSS not found. Please install them using Scoop." -ForegroundColor Yellow
        return
    }

    # Add shortcuts to the startup folder if they don't already exist
    $msiShortcut = Join-Path -Path $startupFolder -ChildPath "MSIAfterburner.lnk"
    $rtssShortcut = Join-Path -Path $startupFolder -ChildPath "RTSS.lnk"

    if (-not (Test-Path $msiShortcut)) {
        Write-Host "Adding MSI Afterburner to startup..." -ForegroundColor Green
        $wshell = New-Object -ComObject WScript.Shell
        $shortcut = $wshell.CreateShortcut($msiShortcut)
        $shortcut.TargetPath = $msiExecutablePath
        $shortcut.Save()
    }
    else {
        Write-Host "MSI Afterburner is already in the startup folder." -ForegroundColor Green
    }

    if (-not (Test-Path $rtssShortcut)) {
        Write-Host "Adding RTSS to startup..." -ForegroundColor Green
        $wshell = New-Object -ComObject WScript.Shell
        $shortcut = $wshell.CreateShortcut($rtssShortcut)
        $shortcut.TargetPath = $rtssExecutablePath
        $shortcut.Save()
    }
    else {
        Write-Host "RTSS is already in the startup folder." -ForegroundColor Green
    }

    Write-Host "Profiles are managed by Scoop and Chezmoi." -ForegroundColor Green
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

    Move-FileSafely -sourcePath $esSourcePath -destinationPath $esDestPath

    # VSCodium Config
    $vscodiumDefaultSourcePath = Join-Path -Path $env:USERPROFILE -ChildPath ".local\share\chezmoi\AppData\Local\installer\vscodium\product.json"
    $vscodiumDestPath = "C:\Program Files\VSCodium\resources\app"

    # Check and update product.json
    if (Test-Path $vscodiumDefaultSourcePath) {
        Move-FileSafely -sourcePath $vscodiumDefaultSourcePath -destinationPath (Join-Path -Path $vscodiumDestPath -ChildPath "product.json")
    }
    else {
        Write-Host "No VSCodium config file (product.json) found in the expected location." -ForegroundColor Yellow
    }
}

function Install-CodeExtensions {
    param(
        [switch]$UpdateJson
    )

    if ($UpdateJson) {
        Write-Host "Updating JSON with current extensions..." -ForegroundColor Cyan
        $jsonFilePath = "$home\.local\share\chezmoi\AppData\Local\installer\code_extensions.json"
        $extensionsData = @{
            vscode   = @()
            vscodium = @()
        }

        # Get VSCode extensions
        if (Get-Command code -ErrorAction SilentlyContinue) {
            $extensionsData.vscode = @(code --list-extensions)
            Write-Host "Found $(($extensionsData.vscode).Count) VSCode extensions" -ForegroundColor Green
        }

        # Get VSCodium extensions
        if (Get-Command codium -ErrorAction SilentlyContinue) {
            $extensionsData.vscodium = @(codium --list-extensions)
            Write-Host "Found $(($extensionsData.vscodium).Count) VSCodium extensions" -ForegroundColor Green
        }

        # Save to JSON
        $extensionsData | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFilePath
        Write-Host "JSON file updated successfully!" -ForegroundColor Green
        return
    }
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

    Write-Host "Starting VSCode/VSCodium extension sync..." -ForegroundColor Cyan
    $jsonFilePath = "$home\.local\share\chezmoi\AppData\Local\installer\code_extensions.json"
    Write-Host "Looking for extensions file at: $jsonFilePath" -ForegroundColor Cyan

    $vscodeInstalled = Get-Command code -ErrorAction SilentlyContinue
    $vscodiumInstalled = Get-Command codium -ErrorAction SilentlyContinue

    if (Test-Path $jsonFilePath) {
        $extensionsData = Get-Content -Path $jsonFilePath | ConvertFrom-Json
        $syncNeeded = $false
        
        if ($vscodeInstalled) {
            $currentVSCodeExtensions = & code --list-extensions
            $desiredVSCodeExtensions = $extensionsData.vscode
            $extensionsToAdd = $desiredVSCodeExtensions | Where-Object { $currentVSCodeExtensions -notcontains $_ }
            $extensionsToRemove = $currentVSCodeExtensions | Where-Object { $desiredVSCodeExtensions -notcontains $_ }

            if ($extensionsToAdd -or $extensionsToRemove) {
                $syncNeeded = $true
                Write-Host "`nVSCode Extensions to Add:" -ForegroundColor Green
                $extensionsToAdd | ForEach-Object { Write-Host "  + $_" }
                
                if ($extensionsToRemove) {
                    Write-Host "`nFound extensions not in JSON file:" -ForegroundColor Yellow
                    $extensionsToRemove | ForEach-Object { Write-Host "  * $_" }
                    $updateChoice = Read-Host "`nDo you want to (K)eep these extensions and update JSON, or (R)emove them? (K/R)"
                    
                    if ($updateChoice -eq 'K') {
                        $extensionsData.vscode += $extensionsToRemove
                        $extensionsData | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFilePath
                        Write-Host "JSON file updated with current extensions" -ForegroundColor Green
                        $extensionsToRemove = @()
                    }
                }

                if ($extensionsToAdd -or $extensionsToRemove) {
                    $confirmation = Read-Host "`nDo you want to apply these changes? (y/n)"
                    if ($confirmation -eq 'y') {
                        $extensionsToAdd | ForEach-Object { & code --install-extension $_ }
                        $extensionsToRemove | ForEach-Object { & code --uninstall-extension $_ }
                    }
                }
            }
            else {
                Write-Host "`nVSCode extensions are in sync!" -ForegroundColor Green
            }
        }

        if ($vscodiumInstalled) {
            $currentVSCodiumExtensions = & codium --list-extensions
            $desiredVSCodiumExtensions = $extensionsData.vscodium
            $extensionsToAdd = $desiredVSCodiumExtensions | Where-Object { $currentVSCodiumExtensions -notcontains $_ }
            $extensionsToRemove = $currentVSCodiumExtensions | Where-Object { $desiredVSCodiumExtensions -notcontains $_ }

            if ($extensionsToAdd -or $extensionsToRemove) {
                $syncNeeded = $true
                Write-Host "`nVSCodium Extensions to Add:" -ForegroundColor Green
                $extensionsToAdd | ForEach-Object { Write-Host "  + $_" }
                
                if ($extensionsToRemove) {
                    Write-Host "`nFound extensions not in JSON file:" -ForegroundColor Yellow
                    $extensionsToRemove | ForEach-Object { Write-Host "  * $_" }
                    $updateChoice = Read-Host "`nDo you want to (K)eep these extensions and update JSON, or (R)emove them? (K/R)"
                    
                    if ($updateChoice -eq 'K') {
                        $extensionsData.vscodium += $extensionsToRemove
                        $extensionsData | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFilePath
                        Write-Host "JSON file updated with current extensions" -ForegroundColor Green
                        $extensionsToRemove = @()
                    }
                }

                if ($extensionsToAdd -or $extensionsToRemove) {
                    $confirmation = Read-Host "`nDo you want to apply these changes? (y/n)"
                    if ($confirmation -eq 'y') {
                        $extensionsToAdd | ForEach-Object { & codium --install-extension $_ }
                        $extensionsToRemove | ForEach-Object { & codium --uninstall-extension $_ }
                    }
                }
            }
            else {
                Write-Host "`nVSCodium extensions are in sync!" -ForegroundColor Green
            }
        }

        if (!$syncNeeded) {
            Write-Host "`nAll extensions are perfectly synced with code_extensions.json!" -ForegroundColor Green
        }
    }
    else {
        Write-Host "Extensions file not found at $jsonFilePath" -ForegroundColor Red
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

function Update-VSCodeExtensions {
    $vscodeInstalled = Get-Command code -ErrorAction SilentlyContinue
    $vscodiumInstalled = Get-Command codium -ErrorAction SilentlyContinue
    $extensionsFilePath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\vscode.txt"

    if (Test-Path $extensionsFilePath) {
        $desiredExtensions = Get-Content -Path $extensionsFilePath
        
        if ($vscodeInstalled) {
            $currentVSCodeExtensions = & code --list-extensions
            $extensionsToAdd = $desiredExtensions | Where-Object { $currentVSCodeExtensions -notcontains $_ }
            $extensionsToRemove = $currentVSCodeExtensions | Where-Object { $desiredExtensions -notcontains $_ }

            if ($extensionsToAdd -or $extensionsToRemove) {
                Write-Host "`nVSCode Extensions to Add:" -ForegroundColor Green
                $extensionsToAdd | ForEach-Object { Write-Host "  + $_" }
                Write-Host "`nVSCode Extensions to Remove:" -ForegroundColor Red
                $extensionsToRemove | ForEach-Object { Write-Host "  - $_" }

                $confirmation = Read-Host "`nDo you want to update VSCode extensions? (y/n)"
                if ($confirmation -eq 'y') {
                    $extensionsToAdd | ForEach-Object { & code --install-extension $_ }
                    $extensionsToRemove | ForEach-Object { & code --uninstall-extension $_ }
                }
            }
        }

        if ($vscodiumInstalled) {
            $currentVSCodiumExtensions = & codium --list-extensions
            $extensionsToAdd = $desiredExtensions | Where-Object { $currentVSCodiumExtensions -notcontains $_ }
            $extensionsToRemove = $currentVSCodiumExtensions | Where-Object { $desiredExtensions -notcontains $_ }

            if ($extensionsToAdd -or $extensionsToRemove) {
                Write-Host "`nVSCodium Extensions to Add:" -ForegroundColor Green
                $extensionsToAdd | ForEach-Object { Write-Host "  + $_" }
                Write-Host "`nVSCodium Extensions to Remove:" -ForegroundColor Red
                $extensionsToRemove | ForEach-Object { Write-Host "  - $_" }

                $confirmation = Read-Host "`nDo you want to update VSCodium extensions? (y/n)"
                if ($confirmation -eq 'y') {
                    $extensionsToAdd | ForEach-Object { & codium --install-extension $_ }
                    $extensionsToRemove | ForEach-Object { & codium --uninstall-extension $_ }
                }
            }
        }
    }
    else {
        Write-Host "Extensions file not found at $extensionsFilePath"
    }
}
# function install-Curls {
#     # Check if already installed
#     $gm320Path = "C:\Program Files (x86)\GM320 RGB"
#     if (Test-Path $gm320Path) {
#         Write-Host "GM320 RGB is already installed at $gm320Path"
#         return
#     }
#
#     # Check if aria2c is installed
#     if (-not (Get-Command aria2c -ErrorAction SilentlyContinue)) {
#         Write-Host "Installing aria2c via Scoop..."
#         scoop install aria2
#     }
#
#     # Rest of your existing code...
#     $documentsPath = [Environment]::GetFolderPath("MyDocuments")
#     $curlsFolder = Join-Path $documentsPath "curls"
#     $zipPath = Join-Path $curlsFolder "mouse.zip"
#     
#     if (-not (Test-Path $curlsFolder)) {
#         Write-Host "Creating curls directory at $curlsFolder..."
#         New-Item -Path $curlsFolder -ItemType Directory | Out-Null
#     }
#     
#     Set-Location $curlsFolder
#     
#     if (-not (Test-Path $zipPath)) {
#         Write-Host "Downloading mouse.zip using aria2c..."
#         $url = "https://drive.google.com/uc?export=download&id=1pa2ryQyBDNiS4aOOYjiOqweFybOrtO3f"
#         $aria2Path = "aria2c"
#         & $aria2Path --dir=$curlsFolder --out="mouse.zip" $url
#     }
#     
#     Write-Host "Extracting files..."
#     $sevenZipPath = "7z"
#     & $sevenZipPath x $zipPath -o$curlsFolder | Out-Null
#     
#     Write-Host "Searching for .exe or .msi files..."
#     $executables = Get-ChildItem -Path $curlsFolder -Recurse -File | Where-Object { $_.Extension -in @(".exe", ".msi") }
#     if ($executables) {
#         foreach ($file in $executables) {
#             Write-Host "Running $($file.Name)..."
#             Start-Process -FilePath $file.FullName -NoNewWindow -Wait
#         }
#     }
#     else {
#         Write-Host "No .exe or .msi files found!"
#     }
# }


function install-Curls {
    # Check if already installed
    $gm320Path = "C:\Program Files (x86)\GM320 RGB"
    if (Test-Path $gm320Path) {
        Write-Host "GM320 RGB is already installed at $gm320Path"
        return
    }

    # Check if gdown is installed via pip
    if (-not (Get-Command gdown -ErrorAction SilentlyContinue)) {
        Write-Host "Installing gdown via pip..."
        pip install gdown
    }

    $documentsPath = [Environment]::GetFolderPath("MyDocuments")
    $curlsFolder = Join-Path $documentsPath "curls"
    $zipPath = Join-Path $curlsFolder "mouse.zip"
    
    if (-not (Test-Path $curlsFolder)) {
        Write-Host "Creating curls directory at $curlsFolder..."
        New-Item -Path $curlsFolder -ItemType Directory | Out-Null
    }
    
    Set-Location $curlsFolder
    # mouse software gm320 
    if (-not (Test-Path $zipPath)) {
        Write-Host "Downloading mouse.zip using gdown..."
        gdown "https://drive.google.com/uc?export=download&id=1pa2ryQyBDNiS4aOOYjiOqweFybOrtO3f"
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

function Set-RegistryValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath,

        [Parameter(Mandatory = $true)]
        [string]$ValueName,

        [Parameter(Mandatory = $true)]
        [object]$Value,

        [Parameter(Mandatory = $true)]
        [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "QWord")]
        [string]$ValueType
    )

    # Check if the registry key exists; if not, create it
    if (-not (Test-Path $RegistryPath)) {
        try {
            New-Item -Path $RegistryPath -Force | Out-Null
            Write-Host "Created registry key: $RegistryPath" -ForegroundColor Yellow
        }
        catch {
            Write-Host "Failed to create registry key: $RegistryPath. Error: $_" -ForegroundColor Red
            return
        }
    }
    else {
        Write-Host "Registry key exists: $RegistryPath" -ForegroundColor Green
    }

    # Retrieve the current value if it exists
    try {
        $CurrentValue = Get-ItemProperty -Path $RegistryPath -Name $ValueName -ErrorAction Stop | Select-Object -ExpandProperty $ValueName
        $ValueExists = $true
    }
    catch {
        $ValueExists = $false
    }

    # Determine the PropertyType based on the ValueType
    switch ($ValueType) {
        "String" { $PropertyType = "String" }
        "ExpandString" { $PropertyType = "ExpandString" }
        "Binary" { $PropertyType = "Binary" }
        "DWord" { $PropertyType = "DWord" }
        "MultiString" { $PropertyType = "MultiString" }
        "QWord" { $PropertyType = "QWord" }
    }

    # Set or update the registry value
    if ($ValueExists) {
        if ($CurrentValue -eq $Value) {
            Write-Host "Value '$ValueName' is already set to '$Value'. No changes made." -ForegroundColor Green
        }
        else {
            try {
                Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $Value
                Write-Host "Changed value of '$ValueName' from '$CurrentValue' to '$Value'." -ForegroundColor Yellow
            }
            catch {
                Write-Host "Failed to change value of '$ValueName'. Error: $_" -ForegroundColor Red
            }
        }
    }
    else {
        try {
            New-ItemProperty -Path $RegistryPath -Name $ValueName -Value $Value -PropertyType $PropertyType -Force | Out-Null
            Write-Host "Created and set value '$ValueName' to '$Value'." -ForegroundColor Yellow
        }
        catch {
            Write-Host "Failed to create and set value '$ValueName'. Error: $_" -ForegroundColor Red
        }
    }
}
# example of using the above function
# $RegistryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
# $ValueName = "EnableTransparency"
# $Value = 1
# $ValueType = "DWord"
#
# Set-RegistryValue -RegistryPath $RegistryPath -ValueName $ValueName -Value $Value -ValueType $ValueType

function Set-TimeZone {
    # Get current time zone
    $currentTimeZone = (Get-TimeZone).Id

    # Check if the current time zone is already set to "India Standard Time"
    if ($currentTimeZone -eq "India Standard Time") {
        Write-Host "Time zone is already set to India Standard Time (IST)." -ForegroundColor Green
    }
    else {
        # If not, set the time zone to India Standard Time
        Set-TimeZone -Name "India Standard Time"
        Write-Host "Time zone has been set to India Standard Time (IST)." -ForegroundColor Green
    }
}



# Start OF THE SCRIPTS FIRST INSTALLING PACKAGE MANAGERS
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
    Write-Host "MLwapp installation Process"
    MLWapp
    Write-Host "=============================================================================================================================================="
    Write-Host "Move config folder"
    Move-ConfigFolder
    Write-Host "=============================================================================================================================================="
    Install-CodeExtensions
    Write-Host "=============================================================================================================================================="
    Set-Wsl
    Write-Host "=============================================================================================================================================="
    ClinkSetup
    Write-Host "=============================================================================================================================================="
    install-Curls

    Write-Host "=============================================================================================================================================="
    Set-TimeZone
    Write-Host "=============================================================================================================================================="
    Add-AdbToPath
    Write-Host "=============================================================================================================================================="

}


$configPath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\packages.json"
$path = Join-Path -Path $HOME -ChildPath ".local\share\chezmoi\AppData\Local\installer\packages.json"
$config = Get-Content -Path $configPath | ConvertFrom-Json

$choice = Read-Host "Choose installation type (mini/full)"
switch ($choice.ToLower()) {
    "mini" {
        # old method get-filehash issue # Install-ScoopPackages -packages $config.scoop.mini
        if (Test-Path "$HOME\scoop\apps\python\current\python.exe") {
            & "$HOME\scoop\apps\python\current\python.exe" "$HOME\.local\share\chezmoi\AppData\Local\installer\scoopmini.py"
        }
        else {
            python "$HOME\.local\share\chezmoi\AppData\Local\installer\scoopmini.py"
        }
        Write-Host "=============================================================================================================================================="
        Install-WingetPackages -packages $config.winget.mini
        Write-Host "=============================================================================================================================================="
        Install-ChocoPackages -packages $config.choco.mini
        Write-Host "=============================================================================================================================================="
    }
    "full" {
        Write-Host "=============================================================================================================================================="
        ## Try scoop python first, fallback to regular python if not available
        if (Test-Path "$HOME\scoop\apps\python\current\python.exe") {
            & "$HOME\scoop\apps\python\current\python.exe" "$HOME\.local\share\chezmoi\AppData\Local\installer\scoopfull.py"
        }
        else {
            python "$HOME\.local\share\chezmoi\AppData\Local\installer\scoopfull.py"
        }
        Write-Host "=============================================================================================================================================="
        pipInstallEssential
        Write-Host "=============================================================================================================================================="
        Install-WingetPackages -packages $config.winget.full
        Write-Host "=============================================================================================================================================="
        Install-ChocoPackages -packages $config.choco.full
        Write-Host "=============================================================================================================================================="
        Set-PermanentMachine
    }
}
Write-Host "Installation completed!" -ForegroundColor Green
function Pin-ChocoPackage {
    param (
        [string]$packageName
    )
    # First check if package is already pinned
    $pinnedPackages = choco pin list | Select-String -Pattern $packageName
    if ($pinnedPackages) {
        Write-Host "$packageName is already pinned. Skipping..."
        return
    }

    # Then check if package is installed
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
    # First check if package is already pinned
    $pinnedPackages = winget pin list | Select-String -Pattern $packageId
    if ($pinnedPackages) {
        Write-Host "$packageId is already pinned. Skipping..."
        return
    }

    # Then check if package is installed
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

# Define packages to pin
$chocoPackagesToPin = @(
    "zoxide",
    "autohotkey"
)

$wingetPackagesToPin = @(
    "AutoHotkey.AutoHotkey",
    "Spotify.Spotify",
    "OliverSchwendener.ueli"
)

Write-Host "=============================================================================================================================="
# Pin Chocolatey packages
Write-Host "Pinning Chocolatey packages..." -ForegroundColor Green
$chocoPackagesToPin | ForEach-Object {
    Pin-ChocoPackage -packageName $_
}

Write-Host "=============================================================================================================================="
# Pin Winget packages
Write-Host "Pinning Winget packages..." -ForegroundColor Green
$wingetPackagesToPin | ForEach-Object {
    Pin-WingetPackage -packageId $_
}

Write-Host "=============================================================================================================================="
