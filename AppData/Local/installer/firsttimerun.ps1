# Function to check if the script is running as Administrator
function Test-Admin {
	$identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
	return $identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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

# Function to install Scoop
function Install-Scoop {
	if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Scoop..."
		if (-not (Test-Admin)) {
			Write-Host "Running Scoop installation with elevated permissions..."
			Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
		}
		else {
			Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)}"
		}
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
$installAll = Read-Host "Do you want to install Scoop, Chocolatey, and Winget? (y/n)"

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
