# Ensure Terminal-Icons module is installed before importing
# now Everything is fixed as per my need for god sake don't chagne or break
# after this
#if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
#    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
#}
#Import-Module -Name Terminal-Icons
## Check if PSReadLine is installed, if not, install it
#if (!(Get-Module -ListAvailable -Name PSReadLine)) {
#    Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
#}
#Import-Module -Name PSReadLine
#
## Ensure the required modules are loaded
#if (-not (Get-Command Expand-Archive -ErrorAction SilentlyContinue)) {
#    Import-Module Microsoft.PowerShell.Archive
#}
# For Terminal-Icons
if ($PSVersionTable.PSVersion.Major -ge 7) {
    if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
    }
    Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue
}

# For PSReadLine
if ($PSVersionTable.PSVersion.Major -ge 7) {
    if (!(Get-Module -ListAvailable -Name PSReadLine)) {
        Install-Module -Name PSReadLine -AllowPrerelease -Force -SkipPublisherCheck
    }
    Import-Module PSReadLine
}
function cha {
    param(
        [Parameter(Mandatory=$true)]
        [string]$path
    )
    chezmoi add $path
}
function chu{
    chezmoi update
}
function scclear{
    scoop cache rm *
}

Set-Alias -Name word -Value "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
Set-Alias -Name xl -Value "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
Set-Alias -Name ppt -Value "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE"
function imginfo{
    $sourceFolder = "G:\photos\organized_media"

# Define photo and video extensions
    $photoExtensions = @("jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic", "webp")
    $videoExtensions = @("mp4", "mov", "avi", "mkv", "wmv", "flv", "webm", "m4v")

# Get all files recursively
    $allFiles = Get-ChildItem -Path $sourceFolder -Recurse -File

# Filter photo and video files separately
    $photoFiles = $allFiles | Where-Object { $photoExtensions -contains $_.Extension.TrimStart(".").ToLower() }
    $videoFiles = $allFiles | Where-Object { $videoExtensions -contains $_.Extension.TrimStart(".").ToLower() }

# Count and size calculations
    $photoCount = $photoFiles.Count
    $photoSize = ($photoFiles | Measure-Object -Property Length -Sum).Sum / 1GB  # Convert to GB

    $videoCount = $videoFiles.Count
    $videoSize = ($videoFiles | Measure-Object -Property Length -Sum).Sum / 1GB  # Convert to GB

    $totalCount = $photoCount + $videoCount
    $totalSize = $photoSize + $videoSize

# Output the results
    Write-Output "Total Photos: $photoCount"
    Write-Output ("Total Photo Size: {0:N2} GB" -f $photoSize)
    Write-Output "Total Videos: $videoCount"
    Write-Output ("Total Video Size: {0:N2} GB" -f $videoSize)
    Write-Output "Total Media Files: $totalCount"
    Write-Output ("Total Media Size: {0:N2} GB" -f $totalSize)
}

function find {
    param (
        [string]$query
    )

    $results = @{}

    # Search in Scoop
    try {
        $scoopResult = scoop search $query
        $results['scoop'] = $scoopResult
    } catch {
        $results['scoop'] = "Error: Unable to search using scoop for $query"
    }

    # Search in Winget
    try {
        $wingetResult = winget search $query
        $results['winget'] = $wingetResult
    } catch {
        $results['winget'] = "Error: Unable to search using winget for $query"
    }

    # Search in Chocolatey (choco)
    try {
        $chocoResult = choco search $query
        $results['choco'] = $chocoResult
    } catch {
        $results['choco'] = "Error: Unable to search using choco for $query"
    }

    # Print results for each tool
    foreach ($tool in $results.Keys) {
        Write-Host "`nResults from ${tool}:`n$($results[$tool])`n----------------------------"
    }
}
# Archive module is built into PS7, so this check isn't needed
# Remove or comment out this section
# if (-not (Get-Command Expand-Archive -ErrorAction SilentlyContinue)) {
#     Import-Module Microsoft.PowerShell.Archive
# }
#if (!(Get-Module -ListAvailable -Name PowerType)) {
#Install-Module PowerType -AllowPrerelease
#Enable-PowerType
#}

function cdwhich {
    param (
        [string]$commandName
    )
    
    # Change location to the source of the provided command
    Set-Location (Get-Command $commandName).Source
}
#this is added
function extedit{
    $ext = Join-Path $HOME "AppData\Local\installer\code_extensions.json"
    #Write-Host "path : "  $ext
    nvim $ext

}
function Show-PathValues {
    Write-Host "System PATH Values:" -ForegroundColor Green
    [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine) -split ';' | ForEach-Object { Write-Output $_ }

    Write-Host "User PATH Values:" -ForegroundColor Cyan
    [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User) -split ';' | ForEach-Object { Write-Output $_ }
}

# Create an alias for the function
Set-Alias -Name spath -Value Show-PathValues
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        Set-Alias -Name cat -Value bat
    }
    else{
        Set-Alias -Name cat -Value cat
    }
#
#function cat {
#    if (Get-Command bat -ErrorAction SilentlyContinue) {
#        #bat @Args
#        Set-Alias -Name cat -Value bat
#    } else {
#        #Get-Content @Args
#    }
#}

function font{
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null; (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
}

#Invoke-Expression (&sfss --hook)

#if (Get-Command sfss -ErrorAction SilentlyContinue) {
#    Invoke-Expression (&sfss --hook)
#} 




function vsync {
	$vscodeInstalled = Get-Command code -ErrorAction SilentlyContinue
	$vscodiumInstalled = Get-Command codium -ErrorAction SilentlyContinue
	$extensionsFilePath = Join-Path $HOME ".local\share\chezmoi\AppData\Local\installer\vscode.txt"

	if (Test-Path $extensionsFilePath) {
		$desiredExtensions = Get-Content -Path $extensionsFilePath
        
		if ($vscodeInstalled) {
			$currentVSCodeExtensions = & code --list-extensions
			$extensionsToAdd = $desiredExtensions | Where-Object { $currentVSCodeExtensions -notcontains $_ }
			$extensionsToRemove = $currentVSCodeExtensions | Where-Object { $desiredExtensions -notcontains $_ }

			if ($extensionsToAdd -or $extensionsToRemove) {
				Write-Host "`nVSCode Extensions to Add:" -ForegroundColor Green
				$extensionsToAdd | ForEach-Object { Write-Host "  + $_" }
				Write-Host "`nVSCode Extensions to Remove:" -ForegroundColor Red
				$extensionsToRemove | ForEach-Object { Write-Host "  - $_" }

				$confirmation = Read-Host "`nDo you want to update VSCode extensions? (y/n)"
				if ($confirmation -eq 'y') {
					$extensionsToAdd | ForEach-Object { & code --install-extension $_ }
					$extensionsToRemove | ForEach-Object { & code --uninstall-extension $_ }
				}
			}
		}

		if ($vscodiumInstalled) {
			$currentVSCodiumExtensions = & codium --list-extensions
			$extensionsToAdd = $desiredExtensions | Where-Object { $currentVSCodiumExtensions -notcontains $_ }
			$extensionsToRemove = $currentVSCodiumExtensions | Where-Object { $desiredExtensions -notcontains $_ }

			if ($extensionsToAdd -or $extensionsToRemove) {
				Write-Host "`nVSCodium Extensions to Add:" -ForegroundColor Green
				$extensionsToAdd | ForEach-Object { Write-Host "  + $_" }
				Write-Host "`nVSCodium Extensions to Remove:" -ForegroundColor Red
				$extensionsToRemove | ForEach-Object { Write-Host "  - $_" }

				$confirmation = Read-Host "`nDo you want to update VSCodium extensions? (y/n)"
				if ($confirmation -eq 'y') {
					$extensionsToAdd | ForEach-Object { & codium --install-extension $_ }
					$extensionsToRemove | ForEach-Object { & codium --uninstall-extension $_ }
				}
			}
		}
	}
 else {
		Write-Host "Extensions file not found at $extensionsFilePath"
	}
}

# Custom key handlers
#Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
#Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
#Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
##Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
#Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
#Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
#Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
#Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
#Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo
function epack{
    $paths = Join-Path $Home "appdata\local\installer\packages.json"
    nvim $paths

}
function his{
    cat (Get-PSReadLineOption).HistorySavePath
}


#function codeext{
#    # Check if VSCode and VSCodium are installed
#    $vscodeInstalled = Get-Command code -ErrorAction SilentlyContinue
#    $vscodiumInstalled = Get-Command codium -ErrorAction SilentlyContinue
#
#    if (-not $vscodeInstalled) {
#        Write-Host "VSCode is not installed. Installing via Chocolatey..."
#        choco install vscode -y
#    }
#    else {
#        Write-Host "VSCode is already installed."
#    }
#
#    if (-not $vscodiumInstalled) {
#        Write-Host "VSCodium is not installed. Installing via Chocolatey..."
#        choco install vscodium -y
#    }
#    else {
#        Write-Host "VSCodium is already installed."
#    }
#
#    # Proceed to manage extensions only if at least one editor is installed
#    if ($vscodeInstalled -or $vscodiumInstalled) {
#        $extensionsFilePath = Join-Path $HOME "AppData\Local\installer\vscode.txt"
#
#        if (Test-Path $extensionsFilePath) {
#            # Read desired extensions from file
#            $desiredExtensions = Get-Content -Path $extensionsFilePath
#
#            # Get currently installed extensions
#            $vscodeExtensions = @()
#            $vscodiumExtensions = @()
#
#            if ($vscodeInstalled) {
#                $vscodeExtensions = & code --list-extensions
#            }
#            if ($vscodiumInstalled) {
#                $vscodiumExtensions = & codium --list-extensions
#            }
#
#            # Handle VSCode Extensions
#            if ($vscodeInstalled) {
#                # Install missing extensions
#                foreach ($extension in $desiredExtensions) {
#                    if ($vscodeExtensions -notcontains $extension) {
#                        Write-Host "Installing VSCode extension: $extension"
#                        & code --install-extension $extension
#                    }
#                }
#
#                # Remove undesired extensions
#                foreach ($installed in $vscodeExtensions) {
#                    if ($desiredExtensions -notcontains $installed) {
#                        Write-Host "Removing VSCode extension: $installed"
#                        & code --uninstall-extension $installed
#                    }
#                }
#            }
#
#            # Handle VSCodium Extensions
#            if ($vscodiumInstalled) {
#                # Install missing extensions
#                foreach ($extension in $desiredExtensions) {
#                    if ($vscodiumExtensions -notcontains $extension) {
#                        Write-Host "Installing VSCodium extension: $extension"
#                        & codium --install-extension $extension
#                    }
#                }
#
#                # Remove undesired extensions
#                foreach ($installed in $vscodiumExtensions) {
#                    if ($desiredExtensions -notcontains $installed) {
#                        Write-Host "Removing VSCodium extension: $installed"
#                        & codium --uninstall-extension $installed
#                    }
#                }
#            }
#
#            Write-Host "Extensions synchronization completed successfully."
#        }
#        else {
#            Write-Host "Extensions file not found at $extensionsFilePath."
#        }
#    }
#    else {
#        Write-Host "Neither VSCode nor VSCodium is installed. Cannot manage extensions."
#    }
#}

Set-Alias -Name rn -Value Rename-Item

Function flist {
    param (
        [string]$SearchTerm = "*"
    )
    Get-ChildItem -Path "C:\Windows\Fonts" | 
    Where-Object { $_.Name -like "*$SearchTerm*" } | 
    Select-Object Name
}
if (Get-Command lsd -ErrorAction SilentlyContinue) {
    Set-Alias ls lsd
}
else {
    Set-Alias ls Get-ChildItem
}
#Remove-Item Alias:zi -ErrorAction SilentlyContinue
function shutit {
    dall
    shutdown /s /t 0
}

#with logo
#fastfetch --logo C:\Users\Manisk\.config\fastfetch\logo.txt
#with default
#fastfetch


# Enhanced PowerShell Experience
# Enhanced PSReadLine Configuration
$PSReadLineOptions = @{
    EditMode = 'Windows'
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
        Command = '#87CEEB'  # SkyBlue (pastel)
        Parameter = '#98FB98'  # PaleGreen (pastel)
        Operator = '#FFB6C1'  # LightPink (pastel)
        Variable = '#DDA0DD'  # Plum (pastel)
        String = '#FFDAB9'  # PeachPuff (pastel)
        Number = '#B0E0E6'  # PowderBlue (pastel)
        Type = '#F0E68C'  # Khaki (pastel)
        Comment = '#D3D3D3'  # LightGray (pastel)
        Keyword = '#8367c7'  # Violet (pastel)
        Error = '#FF6347'  # Tomato (keeping it close to red for visibility)
    }
    PredictionSource = 'History'
    PredictionViewStyle = 'ListView'
    BellStyle = 'None'
}

Set-PSReadLineOption @PSReadLineOptions
if ($Host.Name -notmatch 'ConsoleHost') {
    # Disable predictive suggestions for non-interactive shells
    #Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView # Optional
    Set-PSReadLineOption -PredictionSource None
}
else {
    # Enable predictive suggestions for interactive shells
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView # Optional
    #Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    #Set-PSReadLineOption -PredictionViewStyle ListView
    #can use -EditMode Emacs or Vi mode for folloing the windows one will use windows like home end keybinds   
    Set-PSReadLineOption -EditMode Windows
    
}

# Alias zi to cdi
#Set-Alias -Name zi -Value cdi
#Set-Alias -Name z -Value cd

Set-Alias -Name vim -Value nvim
Set-Alias -Name nivm -Value nvim
Set-Alias -Name vi -Value nvim
#Function update-fzf {
#    Write-Host "Updating fzf cache..."
#    Get-ChildItem -Recurse -Directory $HOME | ForEach-Object { $_.FullName } > $HOME\fzf_dir_cache.txt
#    Get-ChildItem -Recurse -File $HOME | ForEach-Object { $_.FullName } > $HOME\fzf_file_cache.txt
#    Write-Host "fzf cache updated."
#}
#
function rel {
    & $profile
    Write-Host "done"
}
#Function cf {
#    $cacheFile = "$HOME\fzf_dir_cache.txt"
#    if (Test-Path $cacheFile) {
#        $selection = Get-Content $cacheFile | Where-Object { 
#            $_ -notlike "*\.vscode*" -and 
#            $_ -notlike "*\.vscode-oss*" -and
#            $_ -notlike "*\.chade*" -and
#            $_ -notlike "*\.git*" -and
#            $_ -notlike "*node_modules*"  # Add other directories you want to exclude
#        } | fzf --no-sort
#        if ($selection) {
#            Set-Location $selection
#        }
#    }
#    else {
#        Write-Host "Directory cache not found. Generate it using 'Get-ChildItem'."
#    }
#}
#
#Function vic {
#    $cacheFile = "$HOME\fzf_file_cache.txt"
#    if (Test-Path $cacheFile) {
#        $selection = Get-Content $cacheFile | Where-Object { 
#            $_ -notlike "*\.vscode*" -and 
#            $_ -notlike "*\.vscode-oss*" -and
#            $_ -notlike "*\.chade*" -and
#            $_ -notlike "*\.git*" -and
#            $_ -notlike "*node_modules*"  # Add other files you want to exclude
#        } | fzf --no-sort
#        if ($selection) {
#            Set-Location (Split-Path $selection)
#            nvim $selection
#        }
#    }
#    else {
#        Write-Host "File cache not found. Generate it using 'Get-ChildItem'."
#    }
#}

# dotfiles Management
function ff($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.FullName)"
    }
}
function uall {
    scoop update *
    choco upgrade all
    winget upgrade --all
}


function up {
    Set-Location ..
}
#function .. {
#    Set-Location ..
#}

function ... {
    Set-Location ..\..
}
function g. { Set-Location .. }
function pcheck {
    scoop status
    winget upgrade
    choco outdated
}


#only cd to the dir
#function fcd {
#    $dir = Get-ChildItem -Directory | Select-Object -ExpandProperty FullName | fzf --preview 'ls -a {1}' --height 40% --border
#    if ($dir) {
#        # Change location in the current session
#        Set-Location $dir
#    }
#}


#dynamic can go ~ to home or .. one dir up but closes itself
# function fzcd {
#  
#     # Get current location
#     $currentDir = Get-Location
#
#     # Add a "Go Home" option and "Go Up One Level" option
#     $directories = @(
#         "~"  # Go Home
#         ".." # Go Up One Level
#         (Get-ChildItem -Directory -Path $currentDir) | Select-Object -ExpandProperty FullName
#     )
#
#     # Use fzf to let the user select a directory
#     $selectedDir = $directories | fzf --preview 'ls -a {1}' --height 40% --border
#
#     # If user selects a directory, change to that directory
#     if ($selectedDir) {
#         if ($selectedDir -eq "~") {
#             # Go to home directory
#             Set-Location $env:USERPROFILE
#         }
#         elseif ($selectedDir -eq "..") {
#             # Go up one directory
#             Set-Location (Split-Path $currentDir -Parent)
#         }
#         else {
#             # Change to the selected directory
#             Set-Location $selectedDir
#         }
#     }
# }
#

#function fcd {
#    # Get current location
#    $currentDir = Get-Location
#
#    # Add a "Go Home" option and "Go Up One Level" option
#    $directories = @(
#        "~"  # Go Home
#        ".." # Go Up One Level
#        "D:\" # D: drive root
#        "E:\" # E: drive root
#        "F:\" # F: drive root
#        "G:\" # G: drive root
#        (Get-ChildItem -Directory -Path $currentDir -Recurse) | Select-Object -ExpandProperty FullName
#    )
#
#    # Use fzf to let the user select a directory
#    $selectedDir = $directories | fzf --preview 'ls -a {1}' --height 40% --border
#
#    # If user selects a directory, change to that directory
#    if ($selectedDir) {
#        if ($selectedDir -eq "~") {
#            # Go to home directory
#            Set-Location $env:USERPROFILE
#        }
#        elseif ($selectedDir -eq "..") {
#            # Go up one directory
#            Set-Location (Split-Path $currentDir -Parent)
#        }
#        else {
#            # Change to the selected directory
#            Set-Location $selectedDir
#        }
#    }
#}
#
$env:EDITOR = "nvim"
function q { exit }
function st { chezmoi status }
function chm { chezmoi managed }

function cadd {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    chezmoi add $Path
}

function dfor {
    $deletedFiles = chezmoi status | Where-Object { $_ -match '^DA' }
    foreach ($file in $deletedFiles) {
        # Remove "DA" and get the absolute path
        $filePath = $file.Trim() -replace '^DA\s*', ''
        $absolutePath = Join-Path $env:USERPROFILE $filePath

        # Output the absolute path
        Write-Host $absolutePath

        # Forget the file in chezmoi
        chezmoi forget $absolutePath
    }
}

function size {
    param (
        [string]$folderPath
    )

    $folderSize = Get-ChildItem -Path $folderPath -Recurse | Measure-Object -Property Length -Sum
    $folderSizeInMB = [math]::round($folderSize.Sum / 1MB, 2)

    if ($folderSizeInMB -lt 1) {
        $folderSizeInKB = [math]::round($folderSize.Sum / 1KB, 2)
        return "Size : $folderSizeInKB KB"
    }
    else {
        return "$Size : $folderSizeInMB MB"
    }
}

function madd {
    $modifiedFiles = chezmoi status | Where-Object { $_ -match 'MM' }
    foreach ($file in $modifiedFiles) {
        # Remove "MM" and get the absolute path
        $filePath = $file.Trim() -replace '^MM\s*', ''
        $absolutePath = Join-Path $env:USERPROFILE $filePath
        
        # Output the absolute path
        Write-Host $absolutePath
        
        # Add the file to chezmoi
        chezmoi add $absolutePath
    }
}
function lgall {
    git add .
    git commit -m "something"
    git push -u origin master
    
}
function dpush {
    Write-Host "Starting automation"
    Set-Location -Path "$HOME\.local\share\chezmoi"
    git add .
    $userinp = Read-Host -Prompt "Enter commit message"
    git commit -m "$userinp"
    git push -u origin master
    #Set-Location -path "$HOME"
}
function dp {
    Write-Host "Starting automation"
    Set-Location -Path "$HOME\.local\share\chezmoi"
    git add .
    git commit -m "added lazyily .files"
    git push -u origin master
    #Set-Location -path "$HOME"
}

function dall {
    Write-Host "Changes Done..."
    st
    Write-Host ""  # Add an empty line for new line
    Write-Host "Adding all the changes to dot repo"

    # Check for 'DA' elements and call dfor if there are any
    $deletedFiles = chezmoi status | Where-Object { $_ -match '^DA' }
    if ($deletedFiles.Count -gt 0) {
        Write-Host "Deleting any file removed from the Home Directory if any:"
        dfor
        Write-Host ""  # Add an empty line for new line
    }

    madd
    Write-Host ""  # Add an empty line for new line
    Write-Host "Pushing Everything" -ForegroundColor Green
    dp
    Write-Host ""  # Add an empty line for new line
    Set-Location -Path $HOME
}

function gall {
    Set-Location -Path "$HOME\.local\share\chezmoi"
    git add .
    git commit -m "for readme file"
    git push -u origin master
}
function gitall {
    param (
        [Parameter(Mandatory=$true)]
        [string]$commitMessage
    )
    git add . ; git commit -m $commitMessage ; git push
}

function dallm {
    Write-Host "Changes Done..."
    st
    Write-Host ""  # Add an empty line for new line
    Write-Host "Adding all the changes to dot repo"

    # Check for 'DA' elements and call dfor if there are any
    $deletedFiles = chezmoi status | Where-Object { $_ -match '^DA' }
    if ($deletedFiles.Count -gt 0) {
        Write-Host "Deleting any file removed from the Home Directory if any:"
        dfor
        Write-Host ""  # Add an empty line for new line
    }
    madd
    Write-Host ""  # Add an empty line for new line
    Write-Host "Pushing Everything"
    dpush
    Write-Host ""  # Add an empty line for new line
}
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 10000
# Custom completion for common commands
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $customCompletions = @{
        'git'  = @('status', 'add', 'commit', 'push', 'pull', 'clone', 'checkout')
        'npm'  = @('install', 'start', 'run', 'test', 'build')
        'deno' = @('run', 'compile', 'bundle', 'test', 'lint', 'fmt', 'cache', 'info', 'doc', 'upgrade')
    }
    
    $command = $commandAst.CommandElements[0].Value
    if ($customCompletions.ContainsKey($command)) {
        $customCompletions[$command] | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
Register-ArgumentCompleter -Native -CommandName git, npm, deno -ScriptBlock $scriptblock

$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock

#Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
function kvim {
    nvim -u "C:\Users\Manisk\AppData\Local\kvim\init.lua"
}
function kvimc {
    cd "C:\Users\Manisk\AppData\Local\kvim"
}

# Custom functions for PSReadLine
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    $hasSensitive = $sensitive | Where-Object { $line -match $_ }
    return ($null -eq $hasSensitive)
}

# Improved prediction settings
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 10000
# Network Utilities
function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }
# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
Set-Alias -Name su -Value admin
function rel {
    & $profile
}
function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

# Open WinUtil full-release
function winutil {
    irm https://christitus.com/win | iex
}
# Admin Check and Prompt Customization
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function prompt {
    if ($isAdmin) { "[" + (Get-Location) + "] # " } else { "[" + (Get-Location) + "] $ " }
}
$adminSuffix = if ($isAdmin) { " [ADMIN]" } else { "" }
$Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()

function local { cd "C:\Users\Manisk\AppData\Local\" }
function test1 { cd "G:\" }
function roam { cd "C:\Users\Manisk\AppData\Roaming" }
# Quick File Creation
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name }

#Sccache setup lets see fail or not 
$env:SCCACHE_DIR = "C:\sccache_cache"

# env print Shortcuts
function envs {
$env:PATH -split ";"
}
# Directory Management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

Set-Alias -Name ':q' -Value exit
#function lab {cd "c:\new"}
Set-PSReadLineOption -EditMode Vi
function edit { cd "C:\Users\Manisk\AppData\Local\nvim" }
Set-Alias -Name gna -Value Get-NetAdapter
function spshell { cd "C:\Users\Manisk\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" }
function cod { cd "C:\Users\Manisk\Coding\" }
function cods { cd "C:\Users\Manisk\Coding\" }
# Reload the PowerShell profile
function reload-profile {
    & $PROFILE
    Write-Host "Success!"
}
function rel { . $profile }
function rel { & $profile }
Set-Alias e explorer.exe
Set-Alias c vscode.exe
Set-Alias -Name clip -Value Set-Clipboard
Set-Alias -Name dq -Value driverquery

function cf {
    param (
        [string]$filePath
    )
    
    Get-Content $filePath | Set-Clipboard
}

function env { Get-ChildItem Env: }



Function cpyfile {
    param (
        [string]$sourcePath,
        [string]$destinationPath
    )
    
    # Check if the source file exists
    if (Test-Path $sourcePath) {
        # Perform the file copy
        Copy-Item -Path $sourcePath -Destination $destinationPath
        Write-Host "File copied from $sourcePath to $destinationPath"
    }
    else {
        Write-Host "Source file does not exist: $sourcePath"
    }
}


Set-Alias ps Get-Process
Set-Alias rm Remove-Item
Set-Alias cpy Copy-Item
Set-Alias cls Clear-Host
Set-Alias mv Move-Item


function cpycmd {
    param (
        [string]$command
    )

    # Execute the command and capture the output
    $output = Invoke-Expression $command

    # Copy the output to the clipboard
    $output | Set-Clipboard
}

#function cpytree {
#    param (
#        [string]$dirPath
#    )
#
#    # Generate the tree output with /f /a options
#    $treeOutput = & cmd.exe /c "tree $dirPath /f /a"
#
#    # Copy the tree output to the clipboard
#    $treeOutput | Set-Clipboard
#}
function cpytree {
    param (
        [string]$dirPath = (Get-Location).Path # Default to the current directory
    )

    # Directories to exclude
    $excludeDirs = @("node_modules", "next", "build")

    # Generate the tree output with /f /a options
    $treeOutput = & cmd.exe /c "tree $dirPath /f /a"

    # Filter out lines containing the excluded directory names
    $filteredOutput = $treeOutput | Where-Object {
        -not ($_ -match ($excludeDirs -join "|"))
    }

    # Copy the filtered output to the clipboard
    $filteredOutput | Set-Clipboard
}

function cpypath {
    param (
        [string]$path
    )

    # Get the full path (directory + file/folder name)
    $fullPath = (Get-Item $path).FullName
    
    # Copy the full path to the clipboard
    $fullPath | Set-Clipboard
}

function fst { param($searchString) findstr /i "$searchString" }
# Git Shortcuts
function gs { git status }

function ga { git add . }

function gc { param($m) git commit -m "$m" }

function gp { git push }

<# function g { __zoxide_z github } #>

function gcl { git clone "$args" }

function gcom {
    git add .
    git commit -m "$args"
}
function lazyg {
    git add .
    git commit -m "$args"
    git push
}
#find grep a search like in tasklist | fs "search term"
#Set-Alias -Name fs -Value Select-String -Scope Global

function fs {
    param (
        [string]$pattern,
        [string]$path = "." # default to current directory
    )
    # Get only files (not directories) from the specified path and search for the pattern
    Get-ChildItem -Path $path -Recurse -File | 
    Where-Object { $_.Name -match $pattern } | 
    Select-Object -ExpandProperty Name
}
#file manager for console 
function fm { vifm }
Set-Alias recon reload-profile

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
Set-Alias -Name su -Value admin

function npedit { notepad++.exe $PROFILE }


function pkill($name) {
    $process = Get-Process -Name $name -ErrorAction SilentlyContinue
    
    if ($process) {
        # Stop the process if found
        Stop-Process -Name $name -Force
        Write-Host "Process '$name' has been terminated."
    }
    else {
        # Handle the case when the process is not found
        Write-Host "Process '$name' not found."
    }
}

function trash($path) {
    $fullPath = (Resolve-Path -Path $path).Path

    if (Test-Path $fullPath) {
        $item = Get-Item $fullPath

        if ($item.PSIsContainer) {
            # Handle directory
            $parentPath = $item.Parent.FullName
        }
        else {
            # Handle file
            $parentPath = $item.DirectoryName
        }

        $shell = New-Object -ComObject 'Shell.Application'
        $shellItem = $shell.NameSpace($parentPath).ParseName($item.Name)

        if ($item) {
            $shellItem.InvokeVerb('delete')
            Write-Host "Item '$fullPath' has been moved to the Recycle Bin."
        }
        else {
            Write-Host "Error: Could not find the item '$fullPath' to trash."
        }
    }
    else {
        Write-Host "Error: Item '$fullPath' does not exist."
    }
}
function home { cd "C:\Users\Manisk" }
# Navigation Shortcuts
function docs { Set-Location -Path $HOME\Documents }
function doc { Set-Location -Path $HOME\Documents }
function local { Set-Location -Path $HOME\AppData\Local\ }
function roam { Set-Location -path $home\appdata\Roaming\ }
function des { Set-Location -Path $HOME\Desktop }
function dot { Set-Location -Path $Home\.local\share\chezmoi\ }
function dots { Set-Location -Path $Home\.local\share\chezmoi\ }

# Quick Access to Editing the Profile
function ep { nvim $PROFILE }
function eueli {
    nvim "$env:HOME\AppData\Roaming\ueli\config.json"
}
# Simplified Process Management
function k9 { Stop-Process -Name $args[0] }

# Enhanced Listing
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}
function head {
    param($Path, $n = 10)
    Get-Content $Path -Head $n
}

function tail {
    param($Path, $n = 10, [switch]$f = $false)
    Get-Content $Path -Tail $n -Wait:$f
}
#Kills process by name
function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
function pgrep($name) {
    $process = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*$name*" }
    
    if ($process) {
        # Get the unique process names that match
        $matchedNames = $process.ProcessName | Sort-Object -Unique

        foreach ($matchedName in $matchedNames) {
            # Filter processes by the matched name
            $matchedProcesses = $process | Where-Object { $_.ProcessName -eq $matchedName }
            
            # Calculate total CPU and RAM usage for this process name
            $totalCpu = ($matchedProcesses | Measure-Object -Property CPU -Sum).Sum
            $totalRam = ($matchedProcesses | Measure-Object -Property WorkingSet -Sum).Sum / 1MB

            # Get foreground and background subprocess counts
            $subProcesses = Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -in ($matchedProcesses.Id) }
            $foregroundCount = $subProcesses | Where-Object { $_.Handle -ne 0 } | Measure-Object | Select-Object -ExpandProperty Count
            $backgroundCount = $subProcesses | Where-Object { $_.Handle -eq 0 } | Measure-Object | Select-Object -ExpandProperty Count

            # Display process name
            Write-Host "Process Name:" -NoNewline
            Write-Host " $matchedName" -ForegroundColor Cyan

            # Output results with colored CPU and RAM
            Write-Host "CPU:" -NoNewline
            Write-Host " $([math]::Round($totalCpu, 2))%" -ForegroundColor Red -NoNewline
            Write-Host ", RAM:" -NoNewline
            Write-Host " $([math]::Round($totalRam, 2)) MB" -ForegroundColor Green -NoNewline
            Write-Host ", Foreground Processes: $foregroundCount, Background Processes: $backgroundCount"
        }
    }
    else {
        Write-Host "Process '$name' not found." -ForegroundColor Yellow
    }
}



# Quick Access to System Information
function sysinfo { Get-ComputerInfo }


function touch($file) { "" | Out-File $file -Encoding ASCII }
function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}
#shows path of the commands
#function which($name) {
#    Get-Command $name | Select-Object -ExpandProperty Definition
#}
function which($name) {
    # Check if the command exists
    $command = Get-Command $name -ErrorAction SilentlyContinue
    
    if ($null -ne $command) {
        # If the command exists, return its definition
        $command | Select-Object -ExpandProperty Definition
    } else {
        # If the command does not exist, show a message
        Write-Host "Command '$name' does not exist."
    }
}

Set-Alias -Name np -Value Notepad++.exe

function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}


Set-PSReadLineKeyHandler -Key Ctrl+Shift+b `
    -BriefDescription BuildCurrentDirectory `
    -LongDescription "Build the current directory" `
    -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dall")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}


Set-Alias lvim 'C:\Users\Manisk\.local\bin\lvim.ps1'

# Prompt Configuration
# Uncomment only one of the following blocks to enable the desired prompt.

function Get-Theme {
    if (Test-Path -Path $PROFILE.CurrentUserAllHosts -PathType leaf) {
        $existingTheme = Select-String -Raw -Path $PROFILE.CurrentUserAllHosts -Pattern "oh-my-posh init pwsh --config"
        if ($null -ne $existingTheme) {
            Invoke-Expression $existingTheme
            return
        }
        try {
            oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/1_shell.omp.json | Invoke-Expression
        }
        catch {
            try {
                oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json | Invoke-Expression
            }
            catch {
                oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/default.omp.json | Invoke-Expression
            }
        }
    }
    else {
        try {
            oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/1_shell.omp.json | Invoke-Expression
        }
        catch {
            try {
                oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json | Invoke-Expression
            }
            catch {
                oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/default.omp.json | Invoke-Expression
            }
        }
    }
}
# Enable Starship Prompt  To disable Starship, comment this line and uncomment the Oh-My-Posh section.
Invoke-Expression (&starship init powershell)

# Enable Oh-My-Posh Prompt
# Uncomment this section to enable Oh-My-Posh and disable Starship.
 
#Get-Theme


# Zoxide Initialization
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
}
else {
    #Write-Warning "zoxide is not installed. Install it using Scoop or manually from https://github.com/ajeetdsouza/zoxide."
    Write-Host "Zoxide not installed"
    #winget install -e --id ajeetdsouza.zoxide
    #Write-Host "zoxide installed successfully. Initializing..."
    #Write-Host "zoxide not installed"
    #Invoke-Expression (& { (zoxide init powershell | Out-String) })
    try {
        choco install zoxide --version=0.9.0 -y
        #choco pin add --name zoxide
        #winget install -e --id ajeetdsouza.zoxide
        #Write-Host "zoxide installed successfully. Initializing..." -ForegroundColor Cyan
        # Write-Host "zoxide not installed"
        # Invoke-Expression (& { (zoxide init powershell | Out-String) })
    }
    catch {
        Write-Error "Failed to install zoxide. Error: $_"
    }
}
