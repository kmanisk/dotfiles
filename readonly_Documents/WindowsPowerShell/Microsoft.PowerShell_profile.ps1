
# Ensure Terminal-Icons module is installed before importing
# now Everything is fixed as per my need for god sake don't chagne or break
# after this
# if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
#     Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
# }
# Import-Module -Name Terminal-Icons
# Map vi and vim to nvim
## Replace the current Terminal-Icons block with:
if ($PSVersionTable.PSVersion.Major -ge 5) {
    if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
    }
    Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue
}
Function flist {
    param (
        [string]$SearchTerm = "*"
    )
    Get-ChildItem -Path "C:\Windows\Fonts" | 
    Where-Object { $_.Name -like "*$SearchTerm*" } | 
    Select-Object Name
}
if (Get-Command lsd -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    New-Alias -Name ls -Value lsd
}
else {
    Set-Alias ls Get-ChildItem
}
function shutit {
    shutdown /s /t 0
}

# if (Get-Command bat -ErrorAction SilentlyContinue) {
#     Set-Alias -Name cat -Value bat
# }
# else {
#     Set-Alias -Name cat -Value Get-Content
# }
# Replace the current block with:
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    New-Alias -Name cat -Value bat
}
else {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    New-Alias -Name cat -Value Get-Content
}


#with logo
#fastfetch --logo C:\Users\Manisk\.config\fastfetch\logo.txt
#with default
#fastfetch


if ($Host.Name -notmatch 'ConsoleHost') {
    # Disable predictive suggestions for non-interactive shells
    # Set-PSReadLineOption -PredictionSource None
}
else {
    # Enable predictive suggestions for interactive shells
    # Set-PSReadLineOption -PredictionSource HistoryAndPlugin
}

Set-Alias -Name vim -Value nvim
Set-Alias -Name nivm -Value nvim
Set-Alias -Name vi -Value nvim
Function update-fzf {
    Write-Host "Updating fzf cache..."
    Get-ChildItem -Recurse -Directory $HOME | ForEach-Object { $_.FullName } > $HOME\fzf_dir_cache.txt
    Get-ChildItem -Recurse -File $HOME | ForEach-Object { $_.FullName } > $HOME\fzf_file_cache.txt
    Write-Host "fzf cache updated."
}

function rel {
    & $profile
    Write-Host "done"
}


Function cf {
    $cacheFile = "$HOME\fzf_dir_cache.txt"
    if (Test-Path $cacheFile) {
        $selection = Get-Content $cacheFile | Where-Object { 
            $_ -notlike "*\.vscode*" -and 
            $_ -notlike "*\.vscode-oss*" -and
            $_ -notlike "*\.chade*" -and
            $_ -notlike "*\.git*" -and
            $_ -notlike "*node_modules*"  # Add other directories you want to exclude
        } | fzf --no-sort
        if ($selection) {
            Set-Location $selection
        }
    }
    else {
        Write-Host "Directory cache not found. Generate it using 'Get-ChildItem'."
    }
}

Function vic {
    $cacheFile = "$HOME\fzf_file_cache.txt"
    if (Test-Path $cacheFile) {
        $selection = Get-Content $cacheFile | Where-Object { 
            $_ -notlike "*\.vscode*" -and 
            $_ -notlike "*\.vscode-oss*" -and
            $_ -notlike "*\.chade*" -and
            $_ -notlike "*\.git*" -and
            $_ -notlike "*node_modules*"  # Add other files you want to exclude
        } | fzf --no-sort
        if ($selection) {
            Set-Location (Split-Path $selection)
            nvim $selection
        }
    }
    else {
        Write-Host "File cache not found. Generate it using 'Get-ChildItem'."
    }
}

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

#chezmoi add modifiedFiles Automation via one command
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
# Set-PSReadLineOption -PredictionSource HistoryAndPlugin
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

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
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
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
# Set-PSReadLineOption -PredictionSource HistoryAndPlugin
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


Remove-Item Alias:ps -Force -ErrorAction SilentlyContinue
New-Alias -Name ps -Value Get-Process

Remove-Item Alias:rm -Force -ErrorAction SilentlyContinue
New-Alias -Name rm -Value Remove-Item

Remove-Item Alias:cls -Force -ErrorAction SilentlyContinue
New-Alias -Name cls -Value Clear-Host

Remove-Item Alias:mv -Force -ErrorAction SilentlyContinue
New-Alias -Name mv -Value Move-Item
# Set-Alias -Force ps Get-Process
# Set-Alias -Force rm Remove-Item
# Set-Alias -Force cpy Copy-Item
# Set-Alias -Force cls Clear-Host
# Set-Alias -Force mv Move-Item

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
function dotf { cd "G:\dotfiles" }
function eueli { nvim "C:\Users\Manisk\AppData\Roaming\ueli\config.json" }
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
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
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

# Enable Starship Prompt
# To disable Starship, comment this line and uncomment the Oh-My-Posh section.
Invoke-Expression (&starship init powershell)

# Enable Oh-My-Posh Prompt
# Uncomment this section to enable Oh-My-Posh and disable Starship.
 
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
#disable commnet to enable Oh-My-Posh remember to first disable the Starship prompt first 
#Get-Theme


# Zoxide Initialization
# if (Get-Command zoxide -ErrorAction SilentlyContinue) {
#     Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
# }
# else {
#     Write-Warning "zoxide is not installed. Install it using Scoop or manually from https://github.com/ajeetdsouza/zoxide."
#     #winget install -e --id ajeetdsouza.zoxide
#     #Write-Host "zoxide installed successfully. Initializing..."
#     #Write-Host "zoxide not installed"
#     #Invoke-Expression (& { (zoxide init powershell | Out-String) })
#     try {
#         #winget install -e --id ajeetdsouza.zoxide
#         #Write-Host "zoxide installed successfully. Initializing..." -ForegroundColor Cyan
#         # Write-Host "zoxide not installed"
#         # Invoke-Expression (& { (zoxide init powershell | Out-String) })
#     }
#     catch {
#         Write-Error "Failed to install zoxide. Error: $_"
#     }
# }

# Replace the zoxide initialization with this
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --hook prompt | Out-String) })
}
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
