Write-Host "Starting package manager installation..."

# Function to install Scoop
function Install-Scoop {
	if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
		Write-Host "Scoop is not installed. Installing Scoop..."
		Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
		iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
	}
 else {
		Write-Host "Scoop is already installed."
	}

	# Scoop setup
	scoop bucket add main https://github.com/ScoopInstaller/Main.git
	scoop bucket add extras https://github.com/ScoopInstaller/Extras
	scoop bucket add versions https://github.com/ScoopInstaller/Versions
	scoop bucket add nerd-fonts https://github.com/matthewjberger/scoop-nerd-fonts
	scoop bucket add shemnei https://github.com/Shemnei/scoop-bucket
	scoop bucket add volllly https://github.com/volllly/scoop-bucket
}

# Function to install Chocolatey
function Install-Chocolatey {
	if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
		Write-Host "Chocolatey is not installed. Installing Chocolatey..."
		Set-ExecutionPolicy Bypass -Scope Process -Force
		Invoke-WebRequest https://community.chocolatey.org/install.ps1 -OutFile install.ps1
		.\install.ps1
		Remove-Item -Force install.ps1
	}
 else {
		Write-Host "Chocolatey is already installed."
	}

	# Configure Chocolatey settings
	Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
	choco feature enable -n allowGlobalConfirmation
	choco feature enable -n checksumFiles
}

# Function to install Winget
function Install-Winget {
	if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
		Write-Output "winget not found. Installing winget..."
		if ([System.Environment]::OSVersion.Version -ge [Version]"10.0.19041") {
			Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1" -NoNewWindow
			Write-Output "The Microsoft Store is opening. Please install the 'App Installer' package to get winget."
		}
		else {
			Write-Output "Your Windows version does not support winget. Please upgrade to Windows 10 2004 or later."
		}
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

# Install all package managers
Install-Scoop
Install-Chocolatey
Install-Winget

# Prompt the user to choose the installation type
$choice = Read-Host "Choose installation type (minimal/full)"
$installerPath = "c:\Users\Manisk\.local\share\chezmoi\AppData\Local\installer\"

if ($choice -eq "minimal") {
	$packageListFile = "$installerPath\minimal.txt"
	Install-ChocoPackages -packageListFile $packageListFile
}
elseif ($choice -eq "full") {
	$packageListFile = "$installerPath\full.txt"
	Install-ChocoPackages -packageListFile $packageListFile
}
else {
	Write-Host "Invalid choice. Exiting..."
}

Write-Host "All package managers and tools installed successfully!"
