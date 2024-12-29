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
	choco upgrade chocolatey -y
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

# Function to merge Scoop package lists
function Merge-ScoopFiles {
	param (
		[string]$minimalFile,
		[string]$fullFile,
		[string]$mergedFile
	)

	# Check if files exist before merging
	if ((Test-Path $minimalFile) -and (Test-Path $fullFile)) {
		Get-Content $minimalFile, $fullFile | Sort-Object -Unique | Set-Content $mergedFile
		Write-Host "Merged $minimalFile and $fullFile into $mergedFile."
	}
 elseif (Test-Path $minimalFile) {
		Copy-Item $minimalFile $mergedFile
		Write-Host "Only $minimalFile found. Copied to $mergedFile."
	}
 elseif (Test-Path $fullFile) {
		Copy-Item $fullFile $mergedFile
		Write-Host "Only $fullFile found. Copied to $mergedFile."
	}
 else {
		Write-Host "Neither $minimalFile nor $fullFile exists."
	}
}

# Function to install Scoop packages
function Install-ScoopPackages {
	param (
		[string]$packageListFile
	)

	if (-not (Test-Path $packageListFile)) {
		Write-Host "Package list file $packageListFile does not exist."
		return
	}

	Write-Host "Installing tools via Scoop from $packageListFile..."
	Get-Content $packageListFile | ForEach-Object {
		if ($_ -match '\S') {
			scoop install $_
		}
	}
}

# Function to install Chocolatey packages
function Install-ChocoPackages {
	param (
		[string]$packageListFile
	)

	Write-Host "Installing tools via Chocolatey from $packageListFile..."
	Get-Content $packageListFile | ForEach-Object {
		choco install $_ -y
	}
}

# Paths
$installerPath = "$HOME\.local\share\chezmoi\AppData\Local\installer"
$minimalScoopFile = "$installerPath\scoop.txt"
$fullScoopFile = "$installerPath\scoop_full.txt"
$mergedScoopFile = "$installerPath\scoop_merged.txt"
$chocoMinimalFile = "$installerPath\choco_minimal.txt"
$chocoFullFile = "$installerPath\choco_full.txt"

# Merge Scoop files for full installation
Merge-ScoopFiles -minimalFile $minimalScoopFile -fullFile $fullScoopFile -mergedFile $mergedScoopFile

# Install package managers
Install-Scoop
Install-Chocolatey
Install-Winget

# Prompt user for installation type
$choice = Read-Host "Choose installation type (minimal/full)"
switch ($choice.ToLower()) {
	"minimal" {
		# Install minimal Scoop packages
		if (Test-Path $minimalScoopFile) {
			Write-Host "Installing minimal packages via Scoop..."
			Install-ScoopPackages -packageListFile $minimalScoopFile
		}
		else {
			Write-Host "Minimal Scoop package list not found."
		}

		# Install minimal Chocolatey packages
		if (Test-Path $chocoMinimalFile) {
			Write-Host "Installing minimal packages via Chocolatey..."
			Install-ChocoPackages -packageListFile $chocoMinimalFile
		}
		else {
			Write-Host "Minimal Chocolatey package list not found."
		}
	}
	"full" {
		# Install full Scoop packages
		if (Test-Path $mergedScoopFile) {
			Write-Host "Installing full packages via Scoop..."
			Install-ScoopPackages -packageListFile $mergedScoopFile
		}
		else {
			Write-Host "Full Scoop package list not found."
		}

		# Install full Chocolatey packages
		if (Test-Path $chocoFullFile) {
			Write-Host "Installing full packages via Chocolatey..."
			Install-ChocoPackages -packageListFile $chocoFullFile
		}
		else {
			Write-Host "Full Chocolatey package list not found."
		}
	}
	default {
		Write-Host "Invalid choice. Exiting..."
	}
}

Write-Host "Installation completed!"
