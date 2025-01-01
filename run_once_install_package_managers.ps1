
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

Install-Scoop
Install-Chocolatey
Install-Winget

# Load the JSON configuration from the user's home directory
$configPath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\packages.json"
$config = Get-Content -Path $configPath | ConvertFrom-Json

# Function to install Scoop packages
function Install-ScoopPackages {
	param (
		[string[]]$packages
	)
	foreach ($package in $packages) {
		# Install the package using Scoop
		scoop install $package -y
	}
}

# Function to install Winget packages with source flag
function Install-WingetPackages {
	param (
		[string[]]$packages
	)
	foreach ($package in $packages) {
		# Install the package using Winget and specify the source
		winget install $package --source winget -y
	}
}

# Function to install Chocolatey packages
function Install-ChocoPackages {
	param (
		[string[]]$packages
	)
	foreach ($package in $packages) {
		# Install the package using Chocolatey
		choco install $package -y
	}
}

# Prompt the user for installation type
$choice = Read-Host "Choose installation type (mini/full)"
switch ($choice.ToLower()) {
	"mini" {
		# Install mini packages

		# Install Scoop packages
		Install-ScoopPackages -packages $config.scoop.mini

		# Install Winget packages
		Install-WingetPackages -packages $config.winget.mini

		# Install Chocolatey packages
		Install-ChocoPackages -packages $config.choco.mini
	}
	"full" {
		# Install full packages

		# Install Scoop packages
		Install-ScoopPackages -packages $config.scoop.full

		# Install Winget packages
		Install-WingetPackages -packages $config.winget.full

		# Install Chocolatey packages
		Install-ChocoPackages -packages $config.choco.full
	}
	default {
		Write-Host "Invalid choice. Exiting..."
		exit
	}
}

Write-Host "Installation completed!"
