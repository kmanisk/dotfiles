# Write-Host "Starting package installation..."
#
# # Check if Scoop is installed, if not install it
# if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
#     Write-Host "Scoop is not installed. Installing Scoop..."
#     Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
#     iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
# }
# else {
#     Write-Host "Scoop is already installed."
# }
#
# function scoopsetup() {
#     scoop bucket add main https://github.com/ScoopInstaller/Main.git
#     scoop bucket add extras https://github.com/ScoopInstaller/Extras
#     scoop bucket add versions https://github.com/ScoopInstaller/Versions
#     scoop bucket add nerd-fonts https://github.com/matthewjberger/scoop-nerd-fonts
#     scoop bucket add shemnei https://github.com/Shemnei/scoop-bucket
#     scoop bucket add volllly https://github.com/volllly/scoop-bucket
# }
# scoopsetup
# # Install tools via Scoop
# Write-Host "Installing tools via Scoop..."
# scoop install zed cmake 7zip vifm gcc jetbrainsmono-nf-mono innounp winaero-tweaker chezmoi
#
# # Check if Chocolatey is installed, if not install it
# if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
#     Write-Host "Chocolatey is not installed. Installing Chocolatey..."
#     Set-ExecutionPolicy Bypass -Scope Process -Force
#     Invoke-WebRequest https://community.chocolatey.org/install.ps1 -OutFile install.ps1
#     .\install.ps1
#     Remove-Item -Force install.ps1
# }
# else {
#     Write-Host "Chocolatey is already installed."
# }
# # Configure Chocolatey settings
# Write-Host "Configuring Chocolatey settings..." -ForegroundColor Yellow
# choco feature enable -n allowGlobalConfirmation
# choco feature enable -n checksumFiles
# # Install tools via Chocolatey
# Write-Host "Installing tools via Chocolatey..."
# choco install autohotkey vscodium vscode neovim zoxide ripgrep neovide rust starship fastfetch make lsd powershell-core bat lazygit grep greenshot -y
# Write-Host "All packages installed successfully!"
#
#
# function osd-layout {
#     # Set location to the source directory
#     Set-Location -Path "$HOME\.local\share\chezmoi\appdata\local\OSD"
#
#     # Define source directories
#     $msiSource = "msi\Profiles"
#     $rivaSource = "riva\Profiles"
#
#     # Define target directories
#     $msiTarget = "C:\Program Files (x86)\MSI Afterburner\Profiles"
#     $rivaTarget = "C:\Program Files (x86)\RivaTuner Statistics Server\Profiles"
#
#     # Ensure the target directories exist, create them if they don't
#     if (-not (Test-Path $msiTarget)) {
#         Write-Host "Creating MSI Afterburner directory at $msiTarget"
#         New-Item -Path $msiTarget -ItemType Directory
#     }
#     if (-not (Test-Path $rivaTarget)) {
#         Write-Host "Creating RivaTuner directory at $rivaTarget"
#         New-Item -Path $rivaTarget -ItemType Directory
#     }
#
#     # Copy all files and subdirectories from the source directories to the target directories
#     Copy-Item -Path "$msiSource\*" -Destination $msiTarget -Recurse -Force
#     Copy-Item -Path "$rivaSource\*" -Destination $rivaTarget -Recurse -Force
#
#     Write-Host "Files copied successfully to the target locations."
# }
# osd-layout
# function copy-autohotkey-scripts {
#     $sourcePath = "$HOME\.local\share\chezmoi\appdata\local\autohotkey"
#     $startupFolder = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
#
#     # Ensure the source directory exists
#     if (Test-Path $sourcePath) {
#         Write-Host "Running AutoHotkey scripts from $sourcePath..."
#         
#         # Get all .ahk files in the source directory and run them
#         $scripts = Get-ChildItem -Path $sourcePath -Filter *.ahk
#         foreach ($script in $scripts) {
#             Write-Host "Running script: $($script.FullName)"
#             Start-Process -FilePath "AutoHotkey.exe" -ArgumentList "`"$($script.FullName)`"" -NoNewWindow -Wait
#         }
#
#         Write-Host "Copying AutoHotkey scripts from $sourcePath to $startupFolder..."
#         Copy-Item -Path "$sourcePath\*" -Destination $startupFolder -Recurse -Force
#         Write-Host "AutoHotkey scripts copied successfully to the Startup folder."
#     }
#     else {
#         Write-Host "Source directory $sourcePath does not exist."
#     }
# }
#
# function startup () {
#     $startupFolder = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
#     
#     Write-Host "Starting the startup function..."
#     Write-Host "Determining the Startup folder path: $startupFolder"
#     
#     # Call the function to copy AutoHotkey scripts
#     Write-Host "Copying AutoHotkey scripts to the Startup folder..."
#     copy-autohotkey-scripts
#     
#     Write-Host "Startup function completed."
# }
# startup
# function prompt-user {
#     $response = Read-Host "Do you want to proceed terminal and powershell 7? (yes/no)"
#     if ($response -eq "yes") {
#         Write-Host "User chose to proceed with the task."
#         choco install powershell-core microsoft-windows-terminal
#         copy-autohotkey-scripts
#     }
#     else {
#         Write-Host "User chose not to proceed with the task."
#     }
# }
# prompt-user
#
#
Write-Host "run_install_windows_packs.ps1" -ForegroundColor Green