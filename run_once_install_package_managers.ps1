
# Function to install package managers and their packages
function Install-PackageManagers {
	param (
		[string]$configFilePath
	)

	# Read the configuration file
	$config = Get-Content $configFilePath | ConvertFrom-Json

	# Function to install Scoop
	function Install-Scoop {
		if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
			Write-Host "Installing Scoop..."
			Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
			Invoke-Expression (New-Object Net.WebClient).DownloadString('https://get.scoop.sh')
		}
		else {
			Write-Host "Scoop is already installed."
		}
	}

	# Function to install Chocolatey
	function Install-Chocolatey {
		if (-not (Get-Command -Name choco.exe -ErrorAction SilentlyContinue)) {
			Write-Host "Installing Chocolatey..."
			Set-ExecutionPolicy Bypass -Scope Process -Force
			Invoke-WebRequest https://community.chocolatey.org/install.ps1 -OutFile install.ps1
			.\install.ps1
			Remove-Item -Force install.ps1
		}
		else {
			Write-Host "Chocolatey is already installed."
		}
	}

	# Function to install Winget
	function Install-Winget {
		if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
			Write-Host "Installing Winget..."
			# Winget is typically pre-installed with newer Windows versions, or it can be installed through Scoop
			scoop install winget
		}
		else {
			Write-Host "Winget is already installed."
		}
	}

	# Install package managers
	Install-Scoop
	Install-Chocolatey
	Install-Winget

	# Install packages for Scoop
	if ($config.scoop) {
		foreach ($package in $config.scoop) {
			Write-Host "Installing Scoop package: $package"
			scoop install $package
		}
	}

	# Install packages for Winget
	if ($config.winget) {
		foreach ($package in $config.winget) {
			Write-Host "Installing Winget package: $package"
			winget install $package
		}
	}

	# Install packages for Chocolatey
	if ($config.choco) {
		foreach ($package in $config.choco) {
			Write-Host "Installing Chocolatey package: $package"
			choco install $package -y
		}
	}

	Write-Host "Installation completed!"
}

# Path to the configuration file
$configFilePath = "$HOME\.local\share\chezmoi\AppData\Local\installer\packages_config.json"

# Call the function with the path to the configuration file
Install-PackageManagers -configFilePath $configFilePath
