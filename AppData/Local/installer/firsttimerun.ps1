
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
		scoop update
		scoop bucket update *

		# Check and add buckets
		Check-And-AddBucket -bucketName "extras" -bucketUrl ""
		Check-And-AddBucket -bucketName "java" -bucketUrl ""
		Check-And-AddBucket -bucketName "versions" -bucketUrl ""
		Check-And-AddBucket -bucketName "nerd-fonts" -bucketUrl ""
		Check-And-AddBucket -bucketName "volllly" -bucketUrl "https://github.com/volllly/scoop-bucket.git"
		Check-And-AddBucket -bucketName "shemnei" -bucketUrl "https://github.com/Shemnei/scoop-bucket.git"
	}
}
# Function to install Scoop
# function Install-Scoop {
# 	if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
# 		Write-Host "Installing Scoop..."
# 		if (-not (Is-Admin)) {
# 			# Write-Host "Installation under the administrator console has been disabled by default for security considerations."
# 			# Write-Host "If you know what you are doing and want to install Scoop as administrator, please download the installer and manually execute it with the -RunAsAdmin parameter."
# 			# Write-Host "Example:"
# 			# Write-Host "irm get.scoop.sh -outfile 'install.ps1'"
# 			# Write-Host ".\install.ps1 -RunAsAdmin"
# 			# Write-Host "Or use the one-liner command:"
# 			Write-Host "Installing Scoop"
# 			Write-Host "iex ""& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"""
# 		}
# 		else {
# 			Write-Host "Running Scoop installation with elevated permissions..."
# 			Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
# 		}
# 	}
#  else {
# 		Write-Host "Scoop is already installed."
# 		scoop bucket add extras
# 		scoop bucket add java
# 		scoop bucket add versions
# 		scoop bucket add nerd-fonts
#
#
# 		# Define Scoop buckets (excluding main and extras)
# 		# $scoopBuckets = @(
# 		# 	@{ Name = "versions"; URL = "https://github.com/ScoopInstaller/Versions.git" },
# 		# 	@{ Name = "nerd-fonts"; URL = "https://github.com/matthewjberger/scoop-nerd-fonts.git" },
# 		# 	@{ Name = "shemnei"; URL = "https://github.com/Shemnei/scoop-bucket.git" },
# 		# 	@{ Name = "volllly"; URL = "https://github.com/volllly/scoop-bucket.git" }
# 		# )
# 		#
# 		# # Check and add buckets
# 		# foreach ($bucket in $scoopBuckets) {
# 		# 	$bucketInfo = scoop bucket list | Where-Object { $_ -match $bucket.Name }
# 		#
# 		# 	if (-not $bucketInfo) {
# 		# 		# If bucket is not listed, add it
# 		# 		Write-Host "Adding Scoop bucket: $($bucket.Name)"
# 		# 		scoop bucket add $($bucket.Name) $($bucket.URL)
# 		# 	}
# 		# 	else {
# 		# 		# Extract manifest count
# 		# 		$manifestCount = ($bucketInfo -split '\s+')[-1]
# 		# 		if ([int]$manifestCount -eq 0) {
# 		# 			# If manifest count is 0, re-add the bucket
# 		# 			Write-Host "The '$($bucket.Name)' bucket has 0 manifests. Re-adding..."
# 		# 			scoop bucket rm $($bucket.Name)
# 		# 			scoop bucket add $($bucket.Name) $($bucket.URL)
# 		# 		}
# 		# 		else {
# 		# 			Write-Host "The '$($bucket.Name)' bucket already exists with $manifestCount manifests."
# 		# 		}
# 		# 	}
# 		# }
#
# 	}
# }

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
		choco feature enable -n checksumFiles
		# choco install git gh chezmoi -y
	}
	Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
	choco feature enable -n allowGlobalConfirmation
	choco feature enable -n checksumFiles
}
# Install all package managers by default

# Prompt user for installation of Winget
# $userInput = Read-Host -Prompt "Do you want to install Winget? (y/n) [Default: n]"
# # Process user input
# if ($userInput -eq 'y') {
#     Write-Output "Installing Winget..." -ForegroundColor "Green"
#     Install-Winget
# } else {
#     Write-Output "Skipping Winget installation." -ForegroundColor "Yellow"
# }
Install-Scoop
Install-Chocolatey
Install-Winget
Write-Host "Installing first Core Packages..." -ForegroundColor Yellow
winget install twpayne.chezmoi --accept-package-agreements --accept-source-agreements
winget install Git.Git --accept-package-agreements --accept-source-agreements
winget install -e --id GitHub.cli --accept-package-agreements --accept-source-agreements
winget install --id=DEVCOM.JetBrainsMonoNerdFont -e --accept-package-agreements --accept-source-agreements