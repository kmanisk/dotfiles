Write-Host "Starting package manager installation..."

# Function to install Scoop
function Install-Scoop {
	if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
		Write-Host "Scoop is not installed. Installing Scoop..."
		Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
		Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
	}
 else {
		Write-Host "Scoop is already installed."
	}

	# Function to add a Scoop bucket if it does not exist
	function Add-ScoopBucket {
		param (
			[string]$bucketName,
			[string]$bucketUrl
		)

		if (-not (scoop bucket list | Select-String -Pattern $bucketName)) {
			Write-Host "Adding Scoop bucket: $bucketName"
			scoop bucket add $bucketName $bucketUrl
		}
		else {
			Write-Host "The '$bucketName' bucket already exists."
		}
	}

	# Scoop setup with checks
	# Add-ScoopBucket -bucketName "main" -bucketUrl "https://github.com/ScoopInstaller/Main.git"
	# Add-ScoopBucket -bucketName "extras" -bucketUrl "https://github.com/ScoopInstaller/Extras.git"
	Add-ScoopBucket -bucketName "versions" -bucketUrl "https://github.com/ScoopInstaller/Versions.git"
	Add-ScoopBucket -bucketName "nerd-fonts" -bucketUrl "https://github.com/matthewjberger/scoop-nerd-fonts.git"
	Add-ScoopBucket -bucketName "shemnei" -bucketUrl "https://github.com/Shemnei/scoop-bucket.git"
	Add-ScoopBucket -bucketName "volllly" -bucketUrl "https://github.com/volllly/scoop-bucket.git"
}

# Function to install Chocolatey
function Install-Chocolatey {
	if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
		Write-Host "Chocolatey is not installed. Installing Chocolatey..."
		Set-ExecutionPolicy Bypass -Scope Process -Force
		Invoke-WebRequest https://community.chocolatey.org/install.ps1 -OutFile install.ps1
		.\install.ps1
		Remove-Item -Force install.ps1
		[System.Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\ProgramData\chocolatey\bin', 'Machine')
		$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
	}
 else {
		Write-Host "Chocolatey is already installed."
	}

	# Configure Chocolatey settings
	Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
	choco feature enable -n allowGlobalConfirmation
	choco feature enable -n checksumFiles
}

# Pre-install NuGet provider to avoid prompt
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser

# Function to install Winget
function Install-Winget {
	if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
		Write-Output "winget not found. Installing winget..."
		Install-Script winget-install -Force
		winget-install -Force
	}
 else {
		Write-Output "winget is already installed."
	}
}

# Function to install packages via Chocolatey based on a package list file
function Install-ChocoPackages {
	param (
		[string]$packageListFile
	)

	Write-Host "Installing tools via Chocolatey from $packageListFile..."
	Get-Content $packageListFile | ForEach-Object {
		choco install $_ -y
	}
}

# Function to install packages via Scoop based on a package list file
function Install-ScoopPackages {
	param (
		[string]$packageListFile
	)

	Write-Host "Installing tools via Scoop from $packageListFile..."
	Get-Content $packageListFile | ForEach-Object {
		scoop install $_
	}
	scoop install extras/winaero-tweaker
}

# Install all package managers
Install-Scoop
Install-Chocolatey
Install-Winget

# Example usage
$installerPath = "$HOME\.local\share\chezmoi\AppData\Local\installer"
$packageListFile = "$installerPath\scoop.txt"
Install-ScoopPackages -packageListFile $packageListFile

# Prompt the user to choose the installation type
$choice = Read-Host "Choose installation type (minimal/full)"

if ($choice -eq "minimal") {
	$packageListFile = "$installerPath\minimal.txt"
	Install-ChocoPackages -packageListFile $packageListFile
	Install-ScoopPackages -packageListFile "$installerPath\scoop.txt"
}
elseif ($choice -eq "full") {
	$packageListFile = "$installerPath\full.txt"
	Install-ChocoPackages -packageListFile $packageListFile
	Install-ScoopPackages -packageListFile "$installerPath\scoop_full.txt"
}
else {
	Write-Host "Invalid choice. Exiting..."
}

Write-Host "All package managers and tools installed successfully!"
