## Path to the "run once" marker
$runOnceMarker = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\install_done.txt"

# Load the JSON configuration from the user's home directory
$configPath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\packages.json"
$config = Get-Content -Path $configPath | ConvertFrom-Json

# Function to display Scoop packages with an identifier
function Show-ScoopPackages {
	param (
		[string[]]$packages,
		[string]$identifier
	)
	Write-Host "Scoop [$identifier] packages:"
	foreach ($package in $packages) {
		Write-Host " - $package"
	}
}

# Function to display Winget packages with an identifier
function Show-WingetPackages {
	param (
		[string[]]$packages,
		[string]$identifier
	)
	Write-Host "Winget [$identifier] packages:"
	foreach ($package in $packages) {
		Write-Host " - $package"
	}
}

# Function to display Chocolatey packages with an identifier
function Show-ChocoPackages {
	param (
		[string[]]$packages,
		[string]$identifier
	)
	Write-Host "Chocolatey [$identifier] packages:"
	foreach ($package in $packages) {
		Write-Host " - $package"
	}
}

# Check if installation has been run before
if (Test-Path $runOnceMarker) {
	Write-Host "Installation has already been completed. Skipping..."
	exit
}

# Prompt the user for installation type
$choice = Read-Host "Choose installation type (minimal/full)"
switch ($choice.ToLower()) {
	"minimal" {
		# Display minimal packages
		Write-Host "Displaying minimal packages..."

		# Show minimal Scoop packages
		Show-ScoopPackages -packages $config.scoop.minimal -identifier "minimal"

		# Show minimal Winget packages
		Show-WingetPackages -packages $config.winget.minimal -identifier "minimal"

		# Show minimal Chocolatey packages
		Show-ChocoPackages -packages $config.choco.minimal -identifier "minimal"
	}
	"full" {
		# Display full packages
		Write-Host "Displaying full packages..."

		# Show full Scoop packages
		Show-ScoopPackages -packages $config.scoop.full -identifier "full"

		# Show full Winget packages
		Show-WingetPackages -packages $config.winget.full -identifier "full"

		# Show full Chocolatey packages
		Show-ChocoPackages -packages $config.choco.full -identifier "full"
	}
	default {
		Write-Host "Invalid choice. Exiting..."
		exit
	}
}

Write-Host "Test completed! Check the packages displayed."
