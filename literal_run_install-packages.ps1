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
choco feature enable -n allowemptychecksums
# Install tools via Chocolatey
Write-Host "Installing tools via Chocolatey..."
choco install vscodium vscode neovim zoxide neovide rust ueli starship fastfetch make lsd bat lazygit grep greenshot -y
Write-Host "All packages installed successfully!"

#added via edit
