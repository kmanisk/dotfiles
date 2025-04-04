# Ensure Terminal-Icons module is installed before importing
# now Everything is fixed as per my need for god sake don't chagne or break
# after this
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
	Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

# dotfiles Management
$DotFilesPath = "G:\dotfiles"
function ff($name) {
	Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
		Write-Output "$($_.FullName)"
	}
}
function uall {
	scoop update *
	choco upgrade all
}

function g. { Set-Location .. }
function .. { Set-Location ..\.. }
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

function fcd {
	# Get current location
	$currentDir = Get-Location

	# Add a "Go Home" option and "Go Up One Level" option
	$directories = @(
		"~"  # Go Home
		".." # Go Up One Level
		"D:\" # D: drive root
		"E:\" # E: drive root
		"F:\" # F: drive root
		"G:\" # G: drive root
        (Get-ChildItem -Directory -Path $currentDir -Recurse) | Select-Object -ExpandProperty FullName
	)

	# Use fzf to let the user select a directory
	$selectedDir = $directories | fzf --preview 'ls -a {1}' --height 40% --border

	# If user selects a directory, change to that directory
	if ($selectedDir) {
		if ($selectedDir -eq "~") {
			# Go to home directory
			Set-Location $env:USERPROFILE
		}
		elseif ($selectedDir -eq "..") {
			# Go up one directory
			Set-Location (Split-Path $currentDir -Parent)
		}
		else {
			# Change to the selected directory
			Set-Location $selectedDir
		}
	}
}

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
	Get-ChildItem Env:
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
Set-Alias -Name cpy -Value Set-Clipboard
Set-Alias -Name dq -Value driverquery

function cpyfile {
	param (
		[string]$filePath
	)
    
	Get-Content $filePath | Set-Clipboard
}

function env { Get-ChildItem Env: }




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
function cpytree {
	param (
		[string]$dirPath
	)

	# Generate the tree output with /f /a options
	$treeOutput = & cmd.exe /c "tree $dirPath /f /a"

	# Copy the tree output to the clipboard
	$treeOutput | Set-Clipboard
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

# Quick Access to Editing the Profile
function ep { nvim $PROFILE }
function dotf { cd "G:\dotfiles" }
function eueli { nvim "C:\Users\Manisk\AppData\Roaming\ueli\config.json" }
# Simplified Process Management
function k9 { Stop-Process -Name $args[0] }

# Enhanced Listing
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

#Zoxide 
<# Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-Alias -Name cd -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name cdi -Value __zoxide_zi -Option AllScope -Scope Global -Force #>
#Set-Alias -Name cf -Value __zoxide_zi -Option AllScope -Scope Global -Force
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
# find process by name 
# function pgrep($name) {
# $process = Get-Process -Name $name -ErrorAction SilentlyContinue
    
# if ($process) {
#Display the main process
# $processInfo = $process | Select-Object CPU, @{Name="Memory(MB)"; Expression={[math]::round($_.WorkingSet / 1MB, 2)}}, Id, SI, ProcessName
# Write-Host "Main Process:"
# $processInfo
        
#Display subprocesses
# $subProcesses = Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $process.Id }
        
# if ($subProcesses) {
# Write-Host "`nSubprocesses:"
# $subProcesses | Select-Object @{Name="CPU"; Expression={0}}, @{Name="Memory(MB)"; Expression={[math]::round($_.WorkingSetSize / 1MB, 2)}}, ProcessId, @{Name="ParentId"; Expression={$process.Id}}, Name
# } else {
# Write-Host "No subprocesses found for process '$name'."
# }
# } else {
# Write-Host "Process '$name' not found."
# }
# }



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


function ReloadProfile {
	. $PROFILE
}

Set-Alias -Name rpro -Value ReloadProfile
# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

function touch($file) { "" | Out-File $file -Encoding ASCII }
function export($name, $value) {
	set-item -force -path "env:$name" -value $value;
}
#shows path of the commands
function which($name) {
	Get-Command $name | Select-Object -ExpandProperty Definition
}

Set-Alias -Name np -Value Notepad++.exe

function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

# Define the function to set brightness based on a scale of 1 to 10
#function Set-Brightness {
#    param (
#        [int]$Level
#    )
#
#    # Ensure the level is between 1 and 10
#    if ($Level -lt 1 -or $Level -gt 10) {
#        Write-Output "Please enter a level between 1 and 10."
#        return
#    }
#
#    # Calculate brightness on a 0-100 scale
#    $brightnessLevel = ($Level - 1) * 10
#
#    # Get the brightness method and set brightness
#    $brightnessMethod = Get-WmiObject -Namespace root/wmi -Class WmiMonitorBrightnessMethods
#    $brightnessMethod.WmiSetBrightness(1, $brightnessLevel)
#
#    Write-Output "Brightness set to $brightnessLevel%"
#}

# Create an alias for the function
Set-Alias -Name bright -Value Set-Brightness


if (Get-Command zoxide -ErrorAction SilentlyContinue) {
	Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
}
else {
	Write-Host "zoxide command not found. Attempting to install via winget..."
	try {
		winget install -e --id ajeetdsouza.zoxide
		Write-Host "zoxide installed successfully. Initializing..."
		Invoke-Expression (& { (zoxide init powershell | Out-String) })
	}
	catch {
		Write-Error "Failed to install zoxide. Error: $_"
	}
}

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force

# This is an example of a macro that you might use to execute a command.
# This will add the command to history.
Set-PSReadLineKeyHandler -Key Ctrl+Shift+b `
	-BriefDescription BuildCurrentDirectory `
	-LongDescription "Build the current directory" `
	-ScriptBlock {
	[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
	[Microsoft.PowerShell.PSConsoleReadLine]::Insert("dall")
	[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}


Set-Alias lvim 'C:\Users\Manisk\.local\bin\lvim.ps1'
Invoke-Expression (&starship init powershell)

#oh-my-posh init pwsh --config ~/jandedobbeleer.omp.json | Invoke-Expression
#
## Get theme from profile.ps1 or use a default theme
#function Get-Theme {
#    if (Test-Path -Path $PROFILE.CurrentUserAllHosts -PathType leaf) {
#        $existingTheme = Select-String -Raw -Path $PROFILE.CurrentUserAllHosts -Pattern "oh-my-posh init pwsh --config"
#        if ($null -ne $existingTheme) {
#            Invoke-Expression $existingTheme
#            return
#        }
#        oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json | Invoke-Expression
#    } else {
#        oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json | Invoke-Expression
#    }
#} 
#
# Final Line to set prompt
#Get-Theme
