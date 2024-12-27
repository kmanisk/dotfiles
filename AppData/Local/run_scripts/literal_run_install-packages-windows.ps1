Write-Host "Starting package installation..."

# Check if Scoop is installed, if not install it
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
}
else {
    Write-Host "Scoop is already installed."
}

# Install tools via Scoop
Write-Host "Installing tools via Scoop..."
scoop install ripgrep zed cmake 7zip vifm gcc jetbrainsmono-nf-mono innounp winaero-tweaker chezmoi

# Check if Chocolatey is installed, if not install it
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-WebRequest https://community.chocolatey.org/install.ps1 -OutFile install.ps1
    .\install.ps1
    Remove-Item -Force install.ps1
}
else {
    Write-Host "Chocolatey is already installed."
}
# Configure Chocolatey settings
Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
choco feature enable -n allowGlobalConfirmation
choco feature enable -n checksumFiles
# Install tools via Chocolatey
Write-Host "Installing tools via Chocolatey..."
choco install vscodium vscode neovim zoxide neovide rust ueli starship fastfetch make lsd bat lazygit grep greenshot -y
Write-Host "All packages installed successfully!"


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




