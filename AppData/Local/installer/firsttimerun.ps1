# # Function to install Winget
# function Install-Winget {
# 	if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
# 		Write-Host "Installing Winget..."
# 		Install-Script winget-install -Force
# 		winget-install -Force
# 	}
#  else {
# 		Write-Host "Winget is already installed."
# 	}
# }
#
# # Call the function to ensure Winget is installed
# Install-Winget
#
# Write-Host "Installing first Core Packages" -ForegroundColor Yellow
# winget install twpayne.chezmoi
# winget install Git.Git
# winget install -e --id GitHub.cli
#

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

# Function to install Scoop
function Install-Scoop {
	if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Scoop..."
		Invoke-WebRequest get.scoop.sh -UseBasicParsing | Invoke-Expression
	}
 else {
		Write-Host "Scoop is already installed."
	}
}

# Function to install Chocolatey
function Install-Chocolatey {
	if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Chocolatey..."
		Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))	
 }
 else {
		Write-Host "Chocolatey is already installed."
	}
}

# Ask user whether to install all package managers or just Winget
$installAll = Read-Host "(y/n)"

if ($installAll -eq 'y') {
	Install-Scoop
	Install-Chocolatey
}

# Call the function to ensure Winget is installed
Install-Winget

Write-Host "Installing first Core Packages" -ForegroundColor Yellow
winget install twpayne.chezmoi
winget install Git.Git
winget install -e --id GitHub.cli
