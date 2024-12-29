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

# Call the function to ensure Winget is installed
Install-Winget

Write-Host "Installing first Core Packages" -ForegroundColor Yellow
winget install twpayne.chezmoi
winget install Git.Git
winget install -e --id GitHub.cli

winget install --id=Guru3D.Afterburner  -e
winget install --id=Guru3D.RTSS  -e
winget install -e --id TechPowerUp.NVCleanstall