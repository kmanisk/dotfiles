

# Load the JSON configuration from the user's home directory
$configPath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\packages.json"
# Write-Host "Config Path : $configPath"
$config = Get-Content -Path $configPath | ConvertFrom-Json
# Function to install Scoop packages
function Install-ScoopPackages {
	param (
		[string[]]$packages  # Accept an array of package names
	)

	foreach ($package in $packages) {
		Write-Host "Installing Scoop package: $package"
		scoop install $package 
		Write-Host ""
	}
}

# Prompt the user for installation type
$choice = Read-Host "Choose installation type (mini/full)"
switch ($choice.ToLower()) {
	"mini" {
		Install-ScoopPackages -packages $config.scoop.mini
	}
	"full" {
		Install-ScoopPackages -packages $config.scoop.full
	}
}

Write-Host "Installation completed!" -ForegroundColor Green