Write-Host "Starting installation of package managers..."

# Check if Winget is installed, if not install it
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Installing Winget..."
    Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.9.25200/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Add-AppxPackage -Path "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Remove-Item -Force "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
}
# Check if Chocolatey is installed, if not install it
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-WebRequest https://community.chocolatey.org/install.ps1 -OutFile install.ps1
    .\install.ps1
    Remove-Item -Force install.ps1
}

# Check if Scoop is installed, if not install it
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
}

Write-Host "All package managers installed successfully!"

# Install tools via Scoop
Write-Host "Installing tools via Scoop..."
scoop install ripgrep zed cmake 7zip vifm gcc jetbrainsmono-nf-mono innounp winaero-tweaker chezmoi

# Install tools via Winget
Write-Host "Installing tools via Winget..."
winget install --id Microsoft.VisualStudioCode -e --source winget
winget install --id VSCodium.VSCodium -e --source winget
winget install Git.Git

# Install tools via Chocolatey
Write-Host "Installing tools via Chocolatey..."
choco install neovim neovide rust ueli starship fastfetch make lsd bat lazygit grep greenshot -y

Write-Host "All tools installed successfully!"
