
# Function to check if a command exists
function Command-Exists {
	param (
		[string]$command
	)
	return (Get-Command $command -ErrorAction SilentlyContinue) -ne $null
}

# Function to install Scoop
function Install-Scoop {
	Write-Host "Installing Scoop..."
	Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
	Invoke-Expression (New-Object Net.WebClient).DownloadString('https://get.scoop.sh')
}

# Function to install Chocolatey
function Install-Chocolatey {
	Write-Host "Installing Chocolatey..."
	Set-ExecutionPolicy Bypass -Scope Process -Force
	Invoke-WebRequest https://community.chocolatey.org/install.ps1 -OutFile install.ps1
	.\install.ps1
	Remove-Item -Force install.ps1
}

# Function to install Winget
function Install-Winget {
	Write-Host "Installing Winget..."
	Install-Script winget-install -Force
	winget-install -Force
}

# Function to update packages for Scoop, Chocolatey, and Winget
function Update-Packages {
	# Update Scoop packages
	if (Command-Exists "scoop") {
		Write-Host "Updating Scoop packages..."
		scoop update *
	}
 else {
		Install-Scoop
	}

	# Update Chocolatey packages
	if (Command-Exists "choco.exe") {
		Write-Host "Updating Chocolatey packages..."
		choco upgrade all -y
	}
 else {
		Install-Chocolatey
	}

	# Update Winget packages
	if (Command-Exists "winget") {
		Write-Host "Updating Winget packages..."
		winget upgrade --all
	}
 else {
		Install-Winget
	}
}

# Call the function to update packages
Update-Packages

Write-Host "Package managers checked and packages updated or installed as necessary."
