$configPath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\packages.json"
$config = Get-Content -Path $configPath | ConvertFrom-Json

function Install-ScoopPackages {
	param (
		[string[]]$packages
	)

	foreach ($package in $packages) {
		Write-Host "Installing Scoop package: $package"
		scoop install $package 
		Write-Host ""
	}
}

# Directly run mini installation
Install-ScoopPackages -packages $config.scoop.mini

Write-Host "Mini installation completed!" -ForegroundColor Green
