# Function to install Scoop
function Install-Scoop {
	# Check if Scoop is installed
	if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Scoop..."
		Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
		Invoke-Expression (New-Object Net.WebClient).DownloadString('https://get.scoop.sh')
	}
 else {
		Write-Host "Scoop is already installed."
	}

	# Define Scoop buckets (excluding main and extras)
	$scoopBuckets = @(
		@{ Name = "versions"; URL = "https://github.com/ScoopInstaller/Versions.git" },
		@{ Name = "nerd-fonts"; URL = "https://github.com/matthewjberger/scoop-nerd-fonts.git" },
		@{ Name = "shemnei"; URL = "https://github.com/Shemnei/scoop-bucket.git" },
		@{ Name = "volllly"; URL = "https://github.com/volllly/scoop-bucket.git" }
	)

	# Check and add buckets
	foreach ($bucket in $scoopBuckets) {
		$bucketInfo = scoop bucket list | Where-Object { $_ -match $bucket.Name }

		if (-not $bucketInfo) {
			# If bucket is not listed, add it
			Write-Host "Adding Scoop bucket: $($bucket.Name)"
			scoop bucket add $($bucket.Name) $($bucket.URL)
		}
		else {
			# Extract manifest count
			$manifestCount = ($bucketInfo -split '\s+')[-1]
			if ([int]$manifestCount -eq 0) {
				# If manifest count is 0, re-add the bucket
				Write-Host "The '$($bucket.Name)' bucket has 0 manifests. Re-adding..."
				scoop bucket rm $($bucket.Name)
				scoop bucket add $($bucket.Name) $($bucket.URL)
			}
			else {
				Write-Host "The '$($bucket.Name)' bucket already exists with $manifestCount manifests."
			}
		}
	}
}


function Install-Chocolatey {
	# Check if Chocolatey is installed
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

	# Ensure Chocolatey is up to date
	Write-Host "Upgrading Chocolatey to the latest version..."
	# choco upgrade chocolatey -y
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


# # Function to install Chocolatey packages
# function Install-ChocoPackages {
# 	param (
# 		[string]$packageListFile
# 	)

# 	Write-Host "Installing tools via Chocolatey from $packageListFile..."
# 	Get-Content $packageListFile | ForEach-Object {
# 		choco install $_ -y
# 	}
# }

# # Paths
# $installerPath = "$HOME\.local\share\chezmoi\AppData\Local\installer"
# $chocoMinimalFile = "$installerPath\choco_minimal.txt"
# $chocoFullFile = "$installerPath\choco_full.txt"

# # Merge Scoop files for full installation
# Merge-ScoopFiles -minimalFile $minimalScoopFile -fullFile $fullScoopFile -mergedFile $mergedScoopFile
# # Install package managers
# Install-Scoop
# Install-Chocolatey
# Install-Winget

# # Prompt user for installation type
# $choice = Read-Host "Choose installation type (minimal/full)"
# switch ($choice.ToLower()) {
# 	"minimal" {

# 		# Install minimal Chocolatey packages
# 		if (Test-Path $chocoMinimalFile) {
# 			Write-Host "Installing minimal packages via Chocolatey..."
# 			Install-ChocoPackages -packageListFile $chocoMinimalFile
# 		}
# 		else {
# 			Write-Host "Minimal Chocolatey package list not found."
# 		}
# 	}
# 	"full" {
# 		# Install full Chocolatey packages
# 		if (Test-Path $chocoFullFile) {
# 			Write-Host "Installing full packages via Chocolatey..."
# 			Install-ChocoPackages -packageListFile $chocoFullFile
# 		}
# 		else {
# 			Write-Host "Full Chocolatey package list not found."
# 		}
# 	}
# 	default {
# 		Write-Host "Invalid choice. Exiting..."
# 	}
# }

# Write-Host "Installation completed!"
# Load the JSON configuration
$config = Get-Content -Path "$home\appdata\local\" | ConvertFrom-Json

# Function to install packages using Scoop
function Install-ScoopPackages {
	param (
		[string[]]$packages
	)
	foreach ($package in $packages) {
		if (-not (scoop list | Select-String -Pattern $package)) {
			Write-Host "Installing $package via Scoop..."
			scoop install $package
		}
		else {
			Write-Host "$package is already installed via Scoop."
		}
	}
}

# Function to install packages using Winget
function Install-WingetPackages {
	param (
		[string[]]$packages
	)
	foreach ($package in $packages) {
		if (-not (winget list | Select-String -Pattern $package)) {
			Write-Host "Installing $package via Winget..."
			winget install $package
		}
		else {
			Write-Host "$package is already installed via Winget."
		}
	}
}

# Function to install packages using Chocolatey
function Install-ChocoPackages {
	param (
		[string[]]$packages
	)
	foreach ($package in $packages) {
		if (-not (choco list --local-only | Select-String -Pattern $package)) {
			Write-Host "Installing $package via Chocolatey..."
			choco install $package -y
		}
		else {
			Write-Host "$package is already installed via Chocolatey."
		}
	}
}

# Prompt the user for installation type
$choice = Read-Host "Choose installation type (minimal/full)"
switch ($choice.ToLower()) {
	"minimal" {
		# Install minimal packages
		Write-Host "Installing minimal packages..."

		# Install minimal Scoop packages
		Install-ScoopPackages -packages $config.scoop.minimal

		# Install minimal Winget packages
		Install-WingetPackages -packages $config.winget.minimal

		# Install minimal Chocolatey packages
		Install-ChocoPackages -packages $config.choco.minimal
	}
	"full" {
		# Install full packages
		Write-Host "Installing full packages..."

		# Install full Scoop packages
		Install-ScoopPackages -packages $config.scoop.full

		# Install full Winget packages
		Install-WingetPackages -packages $config.winget.full

		# Install full Chocolatey packages
		Install-ChocoPackages -packages $config.choco.full
	}
	default {
		Write-Host "Invalid choice. Exiting..."
	}
}

Write-Host "Installation completed!"
