
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

# Function to install Scoop
function Install-Scoop {
	if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Scoop..."
		if (-not (Is-Admin)) {
			# Write-Host "Installation under the administrator console has been disabled by default for security considerations."
			# Write-Host "If you know what you are doing and want to install Scoop as administrator, please download the installer and manually execute it with the -RunAsAdmin parameter."
			# Write-Host "Example:"
			# Write-Host "irm get.scoop.sh -outfile 'install.ps1'"
			# Write-Host ".\install.ps1 -RunAsAdmin"
			# Write-Host "Or use the one-liner command:"
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
}
function Set-ScoopConfig {
	if (Get-Command scoop -ErrorAction SilentlyContinue) {
		Write-Host "Configuring Scoop settings..." -ForegroundColor Yellow
        
		# Enable aria2 for parallel downloads
		scoop config aria2-enabled true
		scoop config aria2-warning-enabled false
        
		# Set proxy settings if needed
		# scoop config proxy [username:password@]host:port
        
		# Configure default installation directory
		# scoop config SCOOP 'C:\Scoop'
		# scoop config SCOOP_GLOBAL 'C:\ScoopApps'
        
		# Show status
		Write-Host "Current Scoop Configuration:" -ForegroundColor Green
		scoop config show
	}
 else {
		Write-Host "Scoop is not installed. Please install Scoop first." -ForegroundColor Red
	}
}

# Function to install Chocolatey
function Install-Chocolatey {
	if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Chocolatey..."
		Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

		Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
		choco feature enable -n allowGlobalConfirmation
		choco feature enable -n allowemptychecksums
		choco feature enable -n checksumFiles
	}
	else {
		Write-Host "Chocolatey is already installed."

		Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
		choco feature enable -n allowGlobalConfirmation
		choco feature enable -n allowemptychecksums
		choco feature enable -n checksumFiles
		# choco install git gh chezmoi -y
	}
}
function Install-AeroTheme {
	$aeroPath = "C:\Users\Administrator\.local\share\chezmoi\AppData\Local\installer\appconfigs\mouse\Aero\Aero.inf"
    
	if (Test-Path $aeroPath) {
		Write-Host "Installing Windows 10 Aero Theme..."
		Start-Process "rundll32.exe" -ArgumentList "syssetup,SetupInfObjectInstallAction DefaultInstall 128 $aeroPath" -Wait -NoNewWindow
		Write-Host "Aero Theme installation completed"
	}
	else {
		Write-Host "Aero.inf not found at expected location"
	}
}

# Ask user whether to install all package managers or just Winget
# $installAll = Read-Host "Choco and Scoop as well Y/N?"

# if ($installAll -eq 'y') {
Install-Scoop
Write-Host "======================================================"
Install-Chocolatey
Write-Host "======================================================"
# }

Install-AeroTheme
# Call the function to ensure Winget is installed
Install-Winget
Write-Host "======================================================"

Write-Host "Installing first Core Packages" -ForegroundColor Yellow
# scoop packages to install
scoop install main/aria2
scoop install main/chezmoi
scoop install main/git
scoop install main/gh
scoop install main/python

#python installation from msstore
winget install --id 9PNRBTZXMB4Z

# winget install twpayne.chezmoi --accept-package-agreements --accept-source-agreements
#winget install Git.Git --accept-package-agreements --accept-source-agreements
#winget install -e --id GitHub.cli --accept-package-agreements --accept-source-agreements




function pipInstallEssential {
	Write-Host "Installing essential Python packages..."
    
	# List of essential packages
	$packages = @(
		"gdown"
	)

	# Check if gdown is already installed
	if (-not (Get-Command gdown -ErrorAction SilentlyContinue)) {
		# Check if pip is installed
		if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
			Write-Host "Installing pip..."
			python -m ensurepip --upgrade
		}

		# Upgrade pip itself
		python -m pip install --upgrade pip

		# Install each package
		foreach ($package in $packages) {
			Write-Host "Installing $package..."
			pip install $package
		}
	}
	else {
		Write-Host "gdown is already installed, skipping Python package installation"
	}

	Write-Host "Essential Python packages installation completed"
}



function Install-FirstTimePackages {
	# Check if gdown is installed via pip
	if (-not (Get-Command gdown -ErrorAction SilentlyContinue)) {
		Write-Host "Installing gdown via pip..."
		pip install gdown
	}

	$tempPath = [System.IO.Path]::GetTempPath()
	$firstTimeFolder = Join-Path $tempPath "firsttime"
	$downloadedZip = Join-Path $firstTimeFolder "Visual-C-Runtimes-All-in-One-Nov-2024.zip"
    
	if (-not (Test-Path $firstTimeFolder)) {
		Write-Host "Creating firsttime directory at $firstTimeFolder..."
		New-Item -Path $firstTimeFolder -ItemType Directory | Out-Null
	}
    
	Set-Location $firstTimeFolder
    
	if (-not (Test-Path $downloadedZip)) {
		Write-Host "Downloading zip using gdown..."
		gdown "https://drive.google.com/uc?export=download&id=1vrkXd9SfWCBJ8WdyWwICDTEoyYMoXjGA"
	}
    
	Write-Host "Extracting files..."
	Expand-Archive -Path $downloadedZip -DestinationPath $firstTimeFolder -Force
    
	$installBatPath = Join-Path $firstTimeFolder "install_all.bat"
	if (Test-Path $installBatPath) {
		Write-Host "Running install_all.bat..."
		Start-Process -FilePath $installBatPath -NoNewWindow -Wait
	}
	else {
		Write-Host "install_all.bat not found in the extracted files"
	}
}

$confirmation = Read-Host "Do you want to install essential packages and Visual C++ Runtimes? (y/n)"
if ($confirmation -eq 'y') {
	pipInstallEssential
	Write-Host "======================================================"
	Install-FirstTimePackages
	Write-Host "======================================================"
}
# else {
# Write-Host "Installation skipped" -ForegroundColor DarkMagenta
# }

