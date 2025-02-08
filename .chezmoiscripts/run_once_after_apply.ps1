
# Function to check if the script is running as Administrator
function Is-Admin {
	$identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
	return $identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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


function Check-And-AddBucket {
	param (
		[string]$bucketName,
		[string]$bucketUrl
	)

	# Get the list of existing buckets
	$existingBuckets = scoop bucket list

	# Check if the bucket is already in the list
	if ($existingBuckets -notcontains $bucketName) {
		Write-Host "Adding Scoop bucket: $bucketName"
		scoop bucket add $bucketName $bucketUrl
	}
	else {
		Write-Host "Scoop bucket '$bucketName' already exists."
	}
}
# Function to install Scoop
function Install-Scoop {
	if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Scoop..."
		if (-not (Is-Admin)) {
			Write-Host "Installing Scoop"
			Write-Host "iex ""& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"""
		}
		else {
			Write-Host "Running Scoop installation with elevated permissions..."
			Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
		}
	}
	else {
		Write-Host "Scoop is already installed."

		# Check and add buckets
		Check-And-AddBucket -bucketName "extras" -bucketUrl ""
		Check-And-AddBucket -bucketName "java" -bucketUrl ""
		Check-And-AddBucket -bucketName "versions" -bucketUrl ""
		Check-And-AddBucket -bucketName "nerd-fonts" -bucketUrl ""
		Check-And-AddBucket -bucketName "volllly" -bucketUrl "https://github.com/volllly/scoop-bucket.git"
		Check-And-AddBucket -bucketName "shemnei" -bucketUrl "https://github.com/Shemnei/scoop-bucket.git"
	}
}
# Function to install Chocolatey
function Install-Chocolatey {
	if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Chocolatey..."
		Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	}
 else {
		Write-Host "Chocolatey is already installed."

		Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
		choco feature enable -n allowGlobalConfirmation
		choco feature enable -n allowemptychecksums
		choco feature enable -n checksumFiles
	}
	Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
	choco feature enable -n allowGlobalConfirmation
	choco feature enable -n checksumFiles
	choco feature enable -n allowemptychecksums
}
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
		winget pin add --id AutoHotkey.AutoHotkey
		winget upgrade --all
	}
 else {
		Install-Winget
	}
}

# Call the function to update packages
Update-Packages
Write-Host "Package managers checked and packages updated or installed as necessary."
