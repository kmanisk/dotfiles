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

	# Add Scoop buckets
	$scoopBuckets = @{
		"main"       = "https://github.com/ScoopInstaller/Main.git"
		"extras"     = "https://github.com/ScoopInstaller/Extras.git"
		"versions"   = "https://github.com/ScoopInstaller/Versions.git"
		"nerd-fonts" = "https://github.com/matthewjberger/scoop-nerd-fonts.git"
		"shemnei"    = "https://github.com/Shemnei/scoop-bucket.git"
		"volllly"    = "https://github.com/volllly/scoop-bucket.git"
	}
	foreach ($bucket in $scoopBuckets.Keys) {
		if (-not (scoop bucket list | Select-String -Pattern $bucket)) {
			Write-Host "Adding Scoop bucket: $bucket"
			scoop bucket add $bucket $scoopBuckets[$bucket]
		}
		else {
			Write-Host "The '$bucket' bucket already exists."
		}
	}
}

# Function to install Chocolatey
function Install-Chocolatey {
	if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
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

# Pre-install NuGet provider to avoid prompt
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser

# Function to install Winget
function Install-Winget {
	if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Winget..."
		Install-Script -Name winget-install -Force
		winget-install -Force
	}
 else {
		Write-Host "Winget is already installed."
	}
}

# Function to install Chocolatey packages
function Install-ChocoPackages {
	param (
		[string]$packageListFile
	)

	if (-not (Test-Path $packageListFile)) {
		Write-Host "Package list file $packageListFile does not exist."
		return
	}

	Write-Host "Installing tools via Chocolatey from $packageListFile..."
	Get-Content $packageListFile | ForEach-Object {
		if ($_ -match '\S') {
			choco install $_ -y
		}
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

# Function to merge Scoop package lists
function Merge-ScoopFiles {
	param (
		[string]$minimalFile,
		[string]$fullFile,
		[string]$mergedFile
	)

	if (Test-Path $minimalFile -and Test-Path $fullFile) {
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

# Paths
$installerPath = "$HOME\.local\share\chezmoi\AppData\Local\installer"
$minimalScoopFile = "$installerPath\scoop.txt"
$fullScoopFile = "$installerPath\scoop_full.txt"
$mergedScoopFile = "$installerPath\scoop_merged.txt"

# Merge files for full installation
Merge-ScoopFiles -minimalFile $minimalScoopFile -fullFile $fullScoopFile -mergedFile $mergedScoopFile

# Install package managers
Install-Scoop
Install-Chocolatey
Install-Winget

# Prompt user for installation type
$choice = Read-Host "Choose installation type (minimal/full)"
switch ($choice.ToLower()) {
	"minimal" {
		if (Test-Path $minimalScoopFile) {
			Write-Host "Installing minimal packages via Scoop..."
			Install-ScoopPackages -packageListFile $minimalScoopFile
		}
		else {
			Write-Host "Minimal package list not found."
		}
	}
	"full" {
		if (Test-Path $mergedScoopFile) {
			Write-Host "Installing full packages via Scoop..."
			Install-ScoopPackages -packageListFile $mergedScoopFile
		}
		else {
			Write-Host "Full package list not found."
		}
	}
	default {
		Write-Host "Invalid choice. Exiting..."
	}
}

Write-Host "Installation completed!"
