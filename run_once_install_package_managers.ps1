Write-Host "Starting package manager installation..."
# Check if Scoop is installed, if not install it
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
	Write-Host "Scoop is not installed. Installing Scoop..."
	Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
	iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
}
else {
	Write-Host "Scoop is already installed."
}

function scoopsetup() {
	scoop bucket add main https://github.com/ScoopInstaller/Main.git
	scoop bucket add extras https://github.com/ScoopInstaller/Extras
	scoop bucket add versions https://github.com/ScoopInstaller/Versions
	scoop bucket add nerd-fonts https://github.com/matthewjberger/scoop-nerd-fonts
	scoop bucket add shemnei https://github.com/Shemnei/scoop-bucket
	scoop bucket add volllly https://github.com/volllly/scoop-bucket
}
scoopsetup

# Install tools via Scoop
Write-Host "Installing tools via Scoop..."
scoop install zed cmake 7zip vifm gcc jetbrainsmono-nf-mono innounp winaero-tweaker chezmoi

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
choco install autohotkey vscodium vscode neovim zoxide ripgrep neovide rust starship fastfetch make lsd powershell-core bat lazygit grep greenshot -y

Write-Host "All package managers and tools installed successfully!"

# Check if winget is installed
try {
	$wingetVersion = winget --version
	Write-Host "winget is already installed. Version: $wingetVersion"
}
catch {
	Write-Host "winget is not installed. Installing winget..."

	# Install App Installer from Microsoft Store (if not installed)
	$appInstaller = Get-AppxPackage -Name "*AppInstaller*"
	if ($appInstaller -eq $null) {
		Write-Host "App Installer not found. Installing from Microsoft Store..."
		# Open Microsoft Store for App Installer
		Start-Process "ms-windows-store://pdp/?productid=9NBLGGH42THS"
	}
	else {
		Write-Host "App Installer already installed."
	}
}
