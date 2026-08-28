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
function showpack{
    nvim "$HOME\AppData\Local\installer\packages.json"
}
# For PSReadLine
if ($PSVersionTable.PSVersion.Major -ge 7) {
    if (!(Get-Module -ListAvailable -Name PSReadLine)) {
        Install-Module -Name PSReadLine -AllowPrerelease -Force -SkipPublisherCheck
    }
    Import-Module PSReadLine
}
function editdot(){
     nvim "$Home\.local\share\chezmoi\.chezmoiscripts\run_install_windows_packs.ps1"
}

# function editdot() {
#     nvim "$HOME\.local\share\chezmoi\.chezmoiscripts\run_install_windows_packs.ps1"
# }
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

function s{
    param (
        [parameter(mandatory)]
        [string]$query
    )

    clear-host

    function section($title, $color) {
        write-host "`n== $title ==" -foregroundcolor $color
        write-host ("-" * (6 + $title.length)) -foregroundcolor darkgray
    }

    $preferredbuckets = @("extras", "main", "versions")

    # ================= scoop =================
    section "scoop (bucket-aware)" cyan
    try {
        $currentbucket = ""

        $scoopresults =
        scoop search $query 2>$null |
        foreach-object {
            if ($_ -match "^'.+?' bucket:") {
                $currentbucket = ($_ -replace " bucket:", "").trim("'")
            }
            elseif ($_ -match '^\s+(\s+)\s+\(([^)]+)\)') {
                [pscustomobject]@{
                    name    = $matches[1]
                    version = $matches[2]
                    bucket  = $currentbucket
                }
            }
        }

        $scoopresults |
        sort-object `
            @{ expression = { 
                if ($preferredbuckets -contains $_.bucket) {
                    $preferredbuckets.indexof($_.bucket)
                } else {
                    99
                }
            }},
            name,
            version -descending |
        group-object name |
        foreach-object { $_.group | select-object -first 1 } |
        format-table name, version, bucket -autosize

    } catch {
        write-host "scoop search failed" -foregroundcolor red
    }

    # ================= winget =================
    section "winget" green
    try {
        winget search $query --accept-source-agreements |
        select-object -skip 2 |
        foreach-object {
            if ($_ -match '(.+?)\s{2,}(\s+)\s{2,}(\s+)') {
                [pscustomobject]@{
                    name    = $matches[1].trim()
                    version = $matches[3]
                }
            }
        } |
        sort-object name -unique |
        format-table name, version -autosize
    } catch {
        write-host "winget search failed" -foregroundcolor red
    }

    # ================= choco =================
    section "chocolatey" magenta
    try {
        choco search $query --limit-output |
        foreach-object {
            if ($_ -match '^([^|]+)\|(.+)$') {
                [pscustomobject]@{
                    name    = $matches[1]
                    version = $matches[2]
                }
            }
        } |
        sort-object name -unique |
        format-table name, version -autosize
    } catch {
        write-host "choco search failed" -foregroundcolor red
    }
}
function find {
    param (
        [Parameter(Mandatory)]
        [string]$query
    )

    Clear-Host

    function section($title, $color) {
        Write-Host "`n== $title ==" -ForegroundColor $color
        Write-Host ("-" * (6 + $title.Length)) -ForegroundColor DarkGray
    }

    $preferredBuckets = @("extras", "main", "versions")

    # ================= scoop =================
    section "scoop (bucket-aware)" Cyan
    try {
        $currentBucket = $null
        $results = @()

        scoop search $query 2>$null | ForEach-Object {

            # Detect bucket header
            if ($_ -match "^'(.+)' bucket:$") {
                $currentBucket = $matches[1]
                return
            }

            # Detect app line (name + version)
            if ($_ -match '^\s*([a-zA-Z0-9._-]+)\s+([^\s]+)') {
                $results += [pscustomobject]@{
                    Name    = $matches[1]
                    Version = $matches[2]
                    Bucket  = $currentBucket
                }
            }
        }

        $results |
        Sort-Object `
            @{ Expression = {
                if ($preferredBuckets -contains $_.Bucket) {
                    $preferredBuckets.IndexOf($_.Bucket)
                } else { 99 }
            }},
            Name |
        Group-Object Name |
        ForEach-Object { $_.Group | Select-Object -First 1 } |
        Format-Table Name, Version, Bucket -AutoSize
    }
    catch {
        Write-Host "scoop search failed" -ForegroundColor Red
    }

    # ================= winget =================
    section "winget" Green
    try {
        winget search $query --accept-source-agreements 2>$null |
        Where-Object { $_ -match '^\S.*\s{2,}\S' } |
        ForEach-Object {
            $cols = ($_ -split '\s{2,}')

            if ($cols.Length -ge 3) {
                [pscustomobject]@{
                    Name    = $cols[0].Trim()
                    Id      = $cols[1].Trim()
                    Version = $cols[2].Trim()
                }
            }
        } |
        Sort-Object Name -Unique |
        Format-Table Name, Version -AutoSize
    }
    catch {
        Write-Host "winget search failed" -ForegroundColor Red
    }

    # ================= choco =================
    section "chocolatey" Magenta
    try {
        choco search $query --limit-output 2>$null |
        ForEach-Object {
            if ($_ -match '^([^|]+)\|(.+)$') {
                [pscustomobject]@{
                    Name    = $matches[1]
                    Version = $matches[2]
                }
            }
        } |
        Sort-Object Name -Unique |
        Format-Table Name, Version -AutoSize
    }
    catch {
        Write-Host "choco search failed" -ForegroundColor Red
    }
}
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
Set-Alias ng "C:\Users\Manisk\scoop\shims\neovide.exe"
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
    scoop cleanup *
    # choco upgrade all
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
    # choco outdated
}

function wlist {
    $exe = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    & $exe list --source winget $args
}

function winget {
    $exe = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if ($args.Count -ge 1 -and $args[0] -eq "list" -and $args -notcontains "--source" -and $args -notcontains "-s") {
        & $exe list --source winget @($args | Select-Object -Skip 1)
    } else {
        & $exe @args
    }
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
    param(
        [string]$CommitMsg
    )

    Write-Host "Changes Done..."
    st
    Write-Host ""

    # Auto-detect newly installed user fonts and add to packages.json (no deletion)
    $chezmoiPkgs = "$HOME\.local\share\chezmoi\AppData\Local\installer\packages.json"
    $localPkgs   = "$env:LOCALAPPDATA\installer\packages.json"
    $userFonts   = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

    if ((Test-Path $userFonts) -and (Test-Path $chezmoiPkgs)) {
        try {
            $json = Get-Content $chezmoiPkgs -Raw | ConvertFrom-Json -AsHashtable
            $fontList = [System.Collections.Generic.List[object]]::new($json["fonts"])
            $existingSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($f in $fontList) { [void]$existingSet.Add($f.ToString()) }

            $installedFiles = Get-ChildItem -Path $userFonts -Include *.ttf, *.otf -Recurse -ErrorAction SilentlyContinue
            $newAdded = $false
            foreach ($file in $installedFiles) {
                $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name) -replace '(-Bold|-Regular|-Italic|-BoldItalic|-ExtraBold|-SemiBold|-Light|-Medium|-Thin|-Heavy|-Oblique|NerdFont|Mono|_| )+$', ''
                if (-not [string]::IsNullOrWhiteSpace($base) -and -not $existingSet.Contains($base)) {
                    $fontList.Add($base)
                    [void]$existingSet.Add($base)
                    $newAdded = $true
                    Write-Host "Discovered new font: $base (added to packages.json)" -ForegroundColor Green
                }
            }

            if ($newAdded) {
                $json["fonts"] = $fontList
                $json | ConvertTo-Json -Depth 10 | Set-Content $chezmoiPkgs -Encoding UTF8
                if (Test-Path $localPkgs) {
                    $json | ConvertTo-Json -Depth 10 | Set-Content $localPkgs -Encoding UTF8
                }
            }
        } catch {
            Write-Warning "Font check during dall skipped: $_"
        }
    }

    Write-Host "Adding all the changes to dot repo"

    $deletedFiles = chezmoi status | Where-Object { $_ -match '^DA' }
    if ($deletedFiles.Count -gt 0) {
        Write-Host "Deleting any file removed from the Home Directory if any:"
        dfor
        Write-Host ""
    }

    madd
    Write-Host ""

    if ([string]::IsNullOrWhiteSpace($CommitMsg)) {
        dp
    } else {
        Set-Location -Path "$HOME\.local\share\chezmoi"
        git add .
        git commit -m "$CommitMsg"
        git push -u origin master
    }

    Write-Host ""
    Set-Location -Path $HOME
}
# function dall {
#     Write-Host "Changes Done..."
#     st
#     Write-Host ""  # Add an empty line for new line
#     Write-Host "Adding all the changes to dot repo"
#
#     # Check for 'DA' elements and call dfor if there are any
#     $deletedFiles = chezmoi status | Where-Object { $_ -match '^DA' }
#     if ($deletedFiles.Count -gt 0) {
#         Write-Host "Deleting any file removed from the Home Directory if any:"
#         dfor
#         Write-Host ""  # Add an empty line for new line
#     }
#
#     madd
#     Write-Host ""  # Add an empty line for new line
#     Write-Host "Pushing Everything" -ForegroundColor Green
#     dp
#     Write-Host ""  # Add an empty line for new line
#     Set-Location -Path $HOME
# }
#
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
function isadmin{
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if($isAdmin)
{
    Write-Host "Yes" -ForegroundColor Green
}
else{
    Write-Host "No" -ForegroundColor Red
}
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
#edited here
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

# function grep($regex, $dir) {
#     if ( $dir ) {
#         Get-ChildItem $dir | select-string $regex
#         return
#     }
#     $input | select-string $regex
# }
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
# Scoop Advance Search 
. ([ScriptBlock]::Create((& scoop-search --hook | Out-String)))

function cdf {
    $sel = ff | fzf
    if (-not $sel) { return }

    if (Test-Path $sel -PathType Container) {
        Set-Location $sel
    } else {
        Set-Location (Split-Path $sel)
    }
}

function pushrm {
    if ($args.Count -ne 2) {
        Write-Error "Usage: pushrm <local_file> <remote_dir>"
        return
    }

    $LocalFile  = Resolve-Path $args[0]
    $RemoteDir  = $args[1]

    # Ensure remote directory exists (once per file, cheap)
    adb shell "mkdir -p $RemoteDir"

    # Push the file (NO manual quoting)
    adb push $LocalFile $RemoteDir

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✔ Pushed and removed: $($LocalFile.Path)"
        Remove-Item -LiteralPath $LocalFile -Force
    }
    else {
        Write-Warning "✘ Failed: $($LocalFile.Path)"
    }
}
function ngui {
    if ($args.Count -eq 0) {
        neovide
    }
    else {
        neovide @args
    }
}# Profile Settings


$ErrorActionPreference = "Stop"

# Dynamically build the path to your Startup folder
$ahkDir = Join-Path $HOME "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

# --- AutoHotkey Management Functions ---

function Enable-AHK {
    <#
    .SYNOPSIS
    Starts the specific AHK scripts from the Windows Startup folder.
    #>
    $scripts = @("ArrowKeysMapping.ahk", "AutoCorrect_v2.ahk")
    
    foreach ($script in $scripts) {
        $fullPath = Join-Path $ahkDir $script
        
        if (Test-Path $fullPath) {
            # WindowStyle Hidden keeps the console pop-up away
            Start-Process AutoHotkey.exe "`"$fullPath`"" -WindowStyle Hidden
            Write-Host "🚀 Started: $script" -ForegroundColor Green
        } else {
            Write-Warning "Missing script: $fullPath"
        }
    }
}

function fix-scoop{
Get-ChildItem -Path "$env:USERPROFILE\scoop\buckets" -Directory | ForEach-Object {
∙     Write-Host "Resetting $($_.Name)..." -ForegroundColor Cyan
∙     git -C $_.FullName fetch --all
∙     git -C $_.FullName reset --hard "@{u}"  # Quotes prevent the Hashtable error
∙     git -C $_.FullName clean -fd
∙ }
}
function fix-scoop-all {
    Write-Host "--- Starting Scoop Repair ---" -ForegroundColor Cyan

    # 1. Reset Scoop Core (The engine)
    Write-Host "`n[1/3] Resetting Scoop Core..." -ForegroundColor Yellow
    git -C "$env:SCOOP\apps\scoop\current" fetch --all
    git -C "$env:SCOOP\apps\scoop\current" reset --hard origin/master
    git -C "$env:SCOOP\apps\scoop\current" clean -fd

    # 2. Reset All Buckets
    Write-Host "`n[2/3] Resetting all buckets..." -ForegroundColor Yellow
    Get-ChildItem -Path "$env:USERPROFILE\scoop\buckets" -Directory | ForEach-Object {
        Write-Host "  -> Resetting $($_.Name)..." -ForegroundColor Cyan
        git -C $_.FullName fetch --all
        git -C $_.FullName reset --hard "@{u}"
        git -C $_.FullName clean -fd
    }

    # 3. Final Sync & Cleanup
    Write-Host "`n[3/3] Running final update and cleanup..." -ForegroundColor Yellow
    scoop update
    scoop cleanup * # Removes old versions of apps
    # Optional: scoop cache rm * # Uncomment this to clear all downloaded installers

    Write-Host "`n✅ Scoop is healthy and up to date!" -ForegroundColor Green
}
function Disable-AHK {
    <#
    .SYNOPSIS
    Kills all running AutoHotkey process instances.
    #>
    $ahkProcesses = Get-Process AutoHotkey -ErrorAction SilentlyContinue
    
    if ($ahkProcesses) {
        $ahkProcesses | Stop-Process -Force
        Write-Host "🛑 All AutoHotkey scripts disabled." -ForegroundColor Yellow
    } else {
        Write-Host "ℹ️ No AutoHotkey processes are currently running." -ForegroundColor Gray
    }
}

# Run on startup (Optional: remove this line if you only want manual control)
# Enable-AHK
function Convert-WebmToMp4 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("FullName")]
        [string]$InputFile,

        [int]$CRF = 18,
        [string]$Preset = "slow"
    )

    process {
        if (-not (Test-Path -LiteralPath $InputFile)) {
            Write-Error "File not found: $InputFile"
            return
        }

        $ResolvedPath = (Resolve-Path -LiteralPath $InputFile).Path
        $ffmpeg = "ffmpeg"
        $OutputFile = [System.IO.Path]::ChangeExtension($ResolvedPath, ".mp4")

        Write-Host "Converting:" $ResolvedPath "→" $OutputFile
        Write-Host "CRF=$CRF | Preset=$Preset"

        & $ffmpeg `
            -hide_banner `
            -loglevel error `
            -stats `
            -i "$ResolvedPath" `
            -map 0:v:0 -map 0:a:0? `
            -c:v libx264 `
            -preset $Preset `
            -crf $CRF `
            -profile:v high `
            -level 4.2 `
            -pix_fmt yuv420p `
            -movflags +faststart `
            -c:a aac `
            -b:a 192k `
            -ac 2 `
            "$OutputFile"

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✔ Done:" $OutputFile -ForegroundColor Green
        } else {
            Write-Error "✖ ffmpeg failed for $ResolvedPath"
        }
    }
}
function emacs {
    & "C:\Users\Administrator\scoop\apps\emacs\current\bin\emacs.exe" --init-directory "$HOME\.emacs.d" $args
}

#search the package managers for the packages all in one 
function s {
    param (
        [Parameter(Mandatory)]
        [string]$query
    )

    Clear-Host

    function section($title, $color) {
        Write-Host "`n== $title ==" -ForegroundColor $color
        Write-Host ("-" * (6 + $title.Length)) -ForegroundColor DarkGray
    }

    $preferredBuckets = @("extras", "main", "versions")

    # ================= scoop =================
    section "scoop (bucket-aware)" Cyan
    try {
        $currentBucket = $null
        $results = @()

        scoop search $query 2>$null | ForEach-Object {
            # Bucket header line
            if ($_ -match "^'(.+)' bucket:$") {
                $currentBucket = $matches[1]
            }
            # App line: name  version
            elseif ($_ -match '^\s*([a-zA-Z0-9._-]+)\s+([^\s]+)') {
                $results += [pscustomobject]@{
                    Name    = $matches[1]
                    Version = $matches[2]
                    Bucket  = $currentBucket
                }
            }
        }

        $results |
        Sort-Object `
            @{ Expression = {
                if ($preferredBuckets -contains $_.Bucket) {
                    $preferredBuckets.IndexOf($_.Bucket)
                } else { 99 }
            }},
            Name |
        Group-Object Name |
        ForEach-Object { $_.Group | Select-Object -First 1 } |
        Format-Table Name, Version, Bucket -AutoSize
    }
    catch {
        Write-Host "scoop search failed" -ForegroundColor Red
    }

    # ================= winget =================
    section "winget" Green
    try {
        winget search $query --accept-source-agreements |
        Select-Object -Skip 1 |
        Where-Object { $_ -match '\S+\s{2,}\S+' } |
        ForEach-Object {
            $cols = ($_ -split '\s{2,}').Trim()
            if ($cols.Count -ge 3) {
                [pscustomobject]@{
                    Name    = $cols[0]
                    Version = $cols[2]
                }
            }
        } |
        Sort-Object Name -Unique |
        Format-Table Name, Version -AutoSize
    }
    catch {
        Write-Host "winget search failed" -ForegroundColor Red
    }

    # <#
    # # ================= choco =================
    # section "chocolatey" Magenta
    # try {
    #     choco search $query --limit-output |
    #     ForEach-Object {
    #         if ($_ -match '^([^|]+)\|(.+)$') {
    #             [pscustomobject]@{
    #                 Name    = $matches[1]
    #                 Version = $matches[2]
    #             }
    #         }
    #     } |
    #     Sort-Object Name -Unique |
    #     Format-Table Name, Version -AutoSize
    # }
    # catch {
    #     Write-Host "choco search failed" -ForegroundColor Red
    # }
    # #>
}
function fail-clear {
    [CmdletBinding()]
    param()

    Write-Host "`nScanning Scoop apps for failed installs..." -ForegroundColor Cyan

    $failedApps = scoop list |
        Where-Object { $_.Info -match "Install failed" } |
        Select-Object -ExpandProperty Name

    if (-not $failedApps) {
        Write-Host "No failed Scoop packages found." -ForegroundColor Green
        return
    }

    Write-Host "`nFailed packages detected:" -ForegroundColor Yellow
    $failedApps | ForEach-Object {
        Write-Host " - $_"
    }

    $globalRoot = scoop config global_path
    $userRoot   = scoop config root_path

    foreach ($app in $failedApps) {

        Write-Host "`nCleaning: $app" -ForegroundColor Magenta

        try {
            scoop uninstall $app -g *> $null
        } catch {}

        try {
            scoop uninstall $app *> $null
        } catch {}

        $paths = @(
            "$userRoot\apps\$app",
            "$globalRoot\apps\$app",
            "$userRoot\persist\$app",
            "$globalRoot\persist\$app",
            "$userRoot\cache\$app*",
            "$globalRoot\cache\$app*"
        )

        foreach ($path in $paths) {
            Get-Item $path -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }

        Write-Host "Removed broken package: $app" -ForegroundColor Green
    }

    scoop cleanup *

    Write-Host "`nScoop failed-install cleanup complete." -ForegroundColor Cyan
}

function mcpedit {
    nvim "C:\Users\Administrator\.gemini\antigravity-cli\mcp_config.json"
}

# =============================================================================
# Font Management (Install, Remove, List, and Sync with packages.json)
# =============================================================================
function fontmanage {
    <#
    .SYNOPSIS
        Manage Windows fonts and sync font manifests in packages.json.
    .DESCRIPTION
        Install or remove font files (TTF/OTF/ZIP/URL), register/unregister in Windows,
        and update packages.json manifests automatically.
    .EXAMPLE
        fontmanage install C:\Downloads\CozetteVector.ttf
        fontmanage install https://github.com/the-moonwitch/Cozette/releases/download/v.1.30.0/CozetteVector.zip
        fontmanage add Cozette
        fontmanage remove Cozette
        fontmanage list
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [ValidateSet("install", "i", "remove", "rm", "r", "add", "list", "ls", "l", "lf", "help", "h", "-h", "--help", "-help", "/?", "version", "v", "-v", "--version")]
        [string]$Action = "help",

        [Parameter(Position = 1, Mandatory = $false, ValueFromRemainingArguments = $true)]
        [string[]]$Targets
    )

    $chezmoiPkgs = "$HOME\.local\share\chezmoi\AppData\Local\installer\packages.json"
    $localPkgs   = "$env:LOCALAPPDATA\installer\packages.json"
    $userFonts   = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $regKey      = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

    if (-not (Test-Path $userFonts)) {
        New-Item -ItemType Directory -Path $userFonts -Force | Out-Null
    }

    # Helper: update packages.json in both locations
    $updateManifest = {
        param([string]$FontName, [bool]$Add)
        foreach ($p in @($chezmoiPkgs, $localPkgs)) {
            if (Test-Path $p) {
                try {
                    $json = Get-Content $p -Raw | ConvertFrom-Json -AsHashtable
                    $fontList = [System.Collections.Generic.List[object]]::new($json["fonts"])
                    if ($Add) {
                        if ($fontList -notcontains $FontName) {
                            $fontList.Add($FontName)
                            $json["fonts"] = $fontList
                            $json | ConvertTo-Json -Depth 10 | Set-Content $p -Encoding UTF8
                            Write-Host "Added '$FontName' to $p" -ForegroundColor Green
                        }
                    } else {
                        if ($fontList -contains $FontName) {
                            [void]$fontList.Remove($FontName)
                            $json["fonts"] = $fontList
                            $json | ConvertTo-Json -Depth 10 | Set-Content $p -Encoding UTF8
                            Write-Host "Removed '$FontName' from $p" -ForegroundColor Yellow
                        }
                    }
                } catch {
                    Write-Warning "Could not update $p : $_"
                }
            }
        }
    }

    # Helper: broadcast font change
    $notifyFontChange = {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinFontNotifier {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SendNotifyMessage(IntPtr hWnd, int Msg, IntPtr wParam, IntPtr lParam);
}
"@ -ErrorAction SilentlyContinue
        try {
            [WinFontNotifier]::SendNotifyMessage(0xffff, 0x001D, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
        } catch {}
    }

    switch ($Action) {
        { $_ -in "help", "h", "-h", "--help", "-help", "/?" } {
            Write-Host @"
fman - PowerShell Font Manager for Windows

USAGE:
    fman install <repo | url | path>    Install font from GitHub repo, URL, or local file
    fman remove <font_name>             Uninstall a font and remove registry entries
    fman list                           List all installed font families
    fman list -full                     List all individual .ttf / .otf variant files
    fman add <font_name>                Track a font name in packages.json
    fman help                           Show this help message

EXAMPLES:
    fman install the-moonwitch/Cozette
    fman install kika/fixedsys
    fman install IdreesInc/Monocraft
    fman install "https://github.com/.../release.zip"
    fman install "C:\Downloads\CustomFont.ttf"
    fman remove fixedsys
    fman list
    fman list -full
"@ -ForegroundColor Cyan
            return
        }

        { $_ -in "version", "v", "-v", "--version" } {
            Write-Host "fman v1.0.0 - PowerShell Font Manager for Windows" -ForegroundColor Cyan
            return
        }

        { $_ -in "list", "ls", "l", "lf" } {
            $isFull = ($Action -eq "lf") -or ($Targets -contains "full") -or ($Targets -contains "-full") -or ($Targets -contains "-f")

            $installed = Get-ChildItem -Path $userFonts -Include *.ttf, *.otf -Recurse -ErrorAction SilentlyContinue

            if (-not $installed -or $installed.Count -eq 0) {
                Write-Host "No user fonts installed in $userFonts." -ForegroundColor Yellow
                return
            }

            # Group files into clean font families
            $families = @{}
            foreach ($f in $installed) {
                $clean = $f.BaseName -replace '(-Bold|-Regular|-Italic|-BoldItalic|-ExtraBold|-SemiBold|-Light|-Medium|-Thin|-Heavy|-Black|-ExtraLight|-ExtraBlack|-Oblique|-Normal|BoldItalic|BoldUpright|RegularItalic|RegularUpright|_bold|_italic|_regular)+$', ''
                $clean = $clean -replace '[-_]+$', ''
                if ($clean -match '^(FSEX\d+|Fixedsys)') { $clean = "Fixedsys" }
                elseif ($clean -match '^Cozette') { $clean = "Cozette" }
                elseif ($clean -match '^GohuFont') { $clean = "GohuFont" }
                elseif ($clean -match '^Monocraft') { $clean = "Monocraft" }
                elseif ($clean -match '^Iosevka') { $clean = "Iosevka" }
                elseif ($clean -match '^Agave') { $clean = "Agave" }
                elseif ($clean -match '^(Intone|IntelOne)') { $clean = "IntelOneMono" }
                elseif ($clean -match '^(Hurmit|Hermit)') { $clean = "Hermit" }
                elseif ($clean -match '^Fantasque') { $clean = "FantasqueSansMono" }
                elseif ($clean -match '^DaddyTime') { $clean = "DaddyTimeMono" }
                elseif ($clean -match '^Victor') { $clean = "VictorMono" }
                elseif ($clean -match '^(psudo|Pseudo)') { $clean = "PsudoFontLigaMono" }
                elseif ($clean -match '^aporetic-sans') { $clean = "AporeticSansMono" }
                elseif ($clean -match '^aporetic-serif') { $clean = "AporeticSerifMono" }

                if (-not $families.ContainsKey($clean)) {
                    $families[$clean] = [System.Collections.Generic.List[string]]::new()
                }
                $families[$clean].Add($f.Name)
            }

            $pixelKeywords = @("pixel", "bitmap", "craft", "cozette", "gohu", "fixedsys", "terminus", "scientifica", "creep", "tamzen", "unscii", "spleen", "dina")

            $catPixel = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.List[string]]]::new([System.StringComparer]::OrdinalIgnoreCase)
            $catMono  = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.List[string]]]::new([System.StringComparer]::OrdinalIgnoreCase)
            $catOther = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.List[string]]]::new([System.StringComparer]::OrdinalIgnoreCase)

            foreach ($k in $families.Keys) {
                $lower = $k.ToLower()
                $isPixel = $false
                foreach ($kw in $pixelKeywords) {
                    if ($lower -like "*$kw*") { $isPixel = $true; break }
                }

                if ($isPixel) {
                    $catPixel[$k] = $families[$k]
                } elseif ($lower -match "(mono|code|nerd|sans|serif|type|jetbrains|fira|cascadia|consolas|hack|roboto|inconsolata|agave|iosevka|hermit|fantasque|daddy|victor)") {
                    $catMono[$k] = $families[$k]
                } else {
                    $catOther[$k] = $families[$k]
                }
            }

            Write-Host "`n=== INSTALLED USER FONTS ($($families.Count) Families, $($installed.Count) Files) ===" -ForegroundColor Cyan

            if ($catPixel.Count -gt 0) {
                Write-Host "`n[ Pixel & Bitmap Fonts ]" -ForegroundColor Yellow
                foreach ($fam in $catPixel.Keys) {
                    Write-Host "  - $fam ($($catPixel[$fam].Count) variants)" -ForegroundColor White
                    if ($isFull) {
                        foreach ($file in $catPixel[$fam]) {
                            Write-Host "       -> $file" -ForegroundColor DarkGray
                        }
                    }
                }
            }

            if ($catMono.Count -gt 0) {
                Write-Host "`n[ Monospace & Coding Fonts ]" -ForegroundColor Yellow
                foreach ($fam in $catMono.Keys) {
                    Write-Host "  - $fam ($($catMono[$fam].Count) variants)" -ForegroundColor White
                    if ($isFull) {
                        foreach ($file in $catMono[$fam]) {
                            Write-Host "       -> $file" -ForegroundColor DarkGray
                        }
                    }
                }
            }

            if ($catOther.Count -gt 0) {
                Write-Host "`n[ Other Fonts ]" -ForegroundColor Yellow
                foreach ($fam in $catOther.Keys) {
                    Write-Host "  - $fam ($($catOther[$fam].Count) variants)" -ForegroundColor White
                    if ($isFull) {
                        foreach ($file in $catOther[$fam]) {
                            Write-Host "       -> $file" -ForegroundColor DarkGray
                        }
                    }
                }
            }

            if (-not $isFull) {
                Write-Host "`n Tip: Run 'fontmanage list -full' (or 'fman lf') to view all individual .ttf/.otf variant files." -ForegroundColor DarkCyan
            }
        }

        { $_ -in "add" } {
            if (-not $Targets) {
                Write-Error "Please specify a font name to add to packages.json."
                return
            }
            foreach ($t in $Targets) {
                & $updateManifest $t $true
            }
        }

        { $_ -in "install", "i" } {
            if (-not $Targets) {
                Write-Error "Please specify a font path, URL, or font name to install."
                return
            }

            foreach ($target in $Targets) {
                $tempDir = $null
                $filesToInstall = @()
                $inferredName = $target

                # 1. GitHub repo shorthand (e.g. 'the-moonwitch/Cozette', 'kika/fixedsys', 'epk/SF-Mono-Nerd-Font')
                if ($target -match '^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$' -and -not (Test-Path $target)) {
                    Write-Host "Resolving GitHub font files for $target..." -ForegroundColor Cyan
                    $headers = @{ "User-Agent" = "Mozilla/5.0" }
                    if ($env:GITHUB_TOKEN) { $headers["Authorization"] = "token $env:GITHUB_TOKEN" }
                    $downloadUrls = [System.Collections.Generic.List[string]]::new()
                    $isZipList = [System.Collections.Generic.List[bool]]::new()

                    # A. Try GitHub Releases first
                    try {
                        $api = "https://api.github.com/repos/$target/releases/latest"
                        $res = Invoke-RestMethod -Uri $api -Headers $headers -ErrorAction Stop

                        $zipAssets = @($res.assets | Where-Object { $_.name -match "\.zip$" })
                        if ($zipAssets.Count -gt 0) {
                            $best = ($zipAssets | Where-Object { $_.name -match "(font|vector|bundle|release|all)" } | Select-Object -First 1)
                            if (-not $best) { $best = $zipAssets[0] }
                            $downloadUrls.Add($best.browser_download_url)
                            $isZipList.Add($true)
                            Write-Host "Found release font bundle: $($best.name) (Release $($res.tag_name))" -ForegroundColor Green
                        } else {
                            $fontAssets = @($res.assets | Where-Object { $_.name -match "\.(ttf|otf)$" })
                            if ($fontAssets.Count -gt 0) {
                                foreach ($fa in $fontAssets) {
                                    $downloadUrls.Add($fa.browser_download_url)
                                    $isZipList.Add($false)
                                }
                                Write-Host "Found $($fontAssets.Count) font file(s) in Release $($res.tag_name)" -ForegroundColor Green
                            }
                        }
                    } catch {
                        Write-Host "No release found for $target. Searching repository tree..." -ForegroundColor DarkGray
                    }

                    # B. Fallback: Search Repository Tree recursively if no release assets found
                    if ($downloadUrls.Count -eq 0) {
                        try {
                            $treeApi = "https://api.github.com/repos/$target/git/trees/HEAD?recursive=1"
                            $treeRes = Invoke-RestMethod -Uri $treeApi -Headers $headers -ErrorAction Stop
                            $fontBlobs = @($treeRes.tree | Where-Object { $_.type -eq "blob" -and $_.path -match "\.(ttf|otf)$" })

                            if ($fontBlobs.Count -gt 0) {
                                Write-Host "Found $($fontBlobs.Count) font file(s) across $target repository tree." -ForegroundColor Green
                                foreach ($blob in $fontBlobs) {
                                    $rawUrl = "https://raw.githubusercontent.com/$target/HEAD/$($blob.path)"
                                    $downloadUrls.Add($rawUrl)
                                    $isZipList.Add($false)
                                }
                            }
                        } catch {
                            Write-Warning "Tree search failed for $target : $_"
                        }
                    }

                    # Download all resolved assets
                    if ($downloadUrls.Count -gt 0) {
                        $tempDir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
                        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

                        Write-Host "  -> Fetching $($downloadUrls.Count) font file(s) in parallel..." -ForegroundColor Cyan
                        $curlArgs = @("-4", "-fL", "-A", "Mozilla/5.0", "--parallel", "--parallel-immediate", "--retry", "2", "--connect-timeout", "5", "--max-time", "30", "-s")
                        for ($i = 0; $i -lt $downloadUrls.Count; $i++) {
                            $dUrl = $downloadUrls[$i]
                            $fName = [System.IO.Path]::GetFileName(($dUrl -split '\?')[0])
                            $dlFile = Join-Path $tempDir $fName
                            $curlArgs += @("-o", $dlFile, $dUrl)
                        }

                        & curl.exe @curlArgs

                        # Extract any downloaded zip archives
                        Get-ChildItem -Path $tempDir -Filter *.zip -ErrorAction SilentlyContinue | ForEach-Object {
                            Expand-Archive -Path $_.FullName -DestinationPath $tempDir -Force
                        }

                        $filesToInstall = Get-ChildItem -Path $tempDir -Include *.ttf, *.otf -Recurse
                        $inferredName = ($target -split '/')[-1]
                    } else {
                        Write-Warning "No font files (.ttf/.otf/.zip) found in releases or repository tree for $target."
                    }
                }
                # 2. URL Download (Direct Link or Release Asset)
                elseif ($target -match '^https?://') {
                    $tempDir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
                    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
                    $fileName = ($target -split '/')[-1]
                    $dlPath = Join-Path $tempDir $fileName
                    Write-Host "  -> Fetching $fileName..." -ForegroundColor Cyan
                    if (Get-Command 'curl.exe' -ErrorAction SilentlyContinue) {
                        curl.exe -4 -fL --retry 2 --connect-timeout 5 --max-time 30 -A "Mozilla/5.0" -s -o $dlPath $target
                    } else {
                        Invoke-WebRequest -Uri $target -OutFile $dlPath -Headers @{ 'User-Agent' = 'Mozilla/5.0' } -MaximumRedirection 10
                    }

                    if ($fileName -match '\.zip$') {
                        Expand-Archive -Path $dlPath -DestinationPath $tempDir -Force
                        $filesToInstall = Get-ChildItem -Path $tempDir -Include *.ttf, *.otf -Recurse
                    } elseif ($fileName -match '\.(ttf|otf)$') {
                        $filesToInstall = @(Get-Item $dlPath)
                    }
                    $inferredName = ($fileName -replace '\.(zip|ttf|otf)$', '')
                }
                # 3. Local File / Folder / ZIP
                elseif (Test-Path $target) {
                    $item = Get-Item $target
                    if ($item.PSIsContainer) {
                        $filesToInstall = Get-ChildItem -Path $item.FullName -Include *.ttf, *.otf -Recurse
                        $inferredName = $item.Name
                    } elseif ($item.Extension -ieq ".zip") {
                        $tempDir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
                        Expand-Archive -Path $item.FullName -DestinationPath $tempDir -Force
                        $filesToInstall = Get-ChildItem -Path $tempDir -Include *.ttf, *.otf -Recurse
                        $inferredName = [System.IO.Path]::GetFileNameWithoutExtension($item.Name)
                    } elseif ($item.Extension -in @(".ttf", ".otf")) {
                        $filesToInstall = @($item)
                        $inferredName = [System.IO.Path]::GetFileNameWithoutExtension($item.Name)
                    }
                }
                # 4. Font Name (Add to manifest)
                else {
                    & $updateManifest $target $true
                    continue
                }

                # Install font files to User Fonts
                foreach ($f in $filesToInstall) {
                    $dest = Join-Path $userFonts $f.Name
                    try {
                        if (-not (Test-Path $dest)) {
                            Copy-Item $f.FullName $dest -Force -ErrorAction Stop
                        }
                        $fontRegName = "$([System.IO.Path]::GetFileNameWithoutExtension($f.Name)) (TrueType)"
                        Set-ItemProperty -Path $regKey -Name $fontRegName -Value $dest -Force
                        Write-Host "Installed: $($f.Name)" -ForegroundColor Green
                    } catch {
                        Write-Host "Skipped (in use/already present): $($f.Name)" -ForegroundColor DarkGray
                    }
                }

                if ($filesToInstall.Count -gt 0) {
                    & $notifyFontChange
                    & $updateManifest $inferredName $true
                    Write-Host "Font '$inferredName' successfully installed and registered!" -ForegroundColor Green
                }

                if ($tempDir -and (Test-Path $tempDir)) {
                    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }

        { $_ -in "remove", "rm", "r" } {
            if (-not $Targets) {
                Write-Error "Please specify a font name to remove."
                return
            }

            foreach ($target in $Targets) {
                $pattern = "*$target*"
                $foundFiles = Get-ChildItem -Path $userFonts -Filter $pattern -Include *.ttf, *.otf -Recurse -ErrorAction SilentlyContinue
                if ($foundFiles) {
                    foreach ($f in $foundFiles) {
                        Remove-Item $f.FullName -Force -ErrorAction SilentlyContinue
                        Write-Host "Deleted font file: $($f.Name)" -ForegroundColor Yellow
                    }
                }

                # Remove registry entries
                $regEntries = Get-ItemProperty -Path $regKey -ErrorAction SilentlyContinue
                if ($regEntries) {
                    $props = $regEntries.PSObject.Properties | Where-Object { $_.Name -like "*$target*" -or $_.Value -like "*$target*" }
                    foreach ($prop in $props) {
                        Remove-ItemProperty -Path $regKey -Name $prop.Name -ErrorAction SilentlyContinue
                        Write-Host "Removed registry font: $($prop.Name)" -ForegroundColor Yellow
                    }
                }

                & $notifyFontChange
                & $updateManifest $target $false
                Write-Host "Font '$target' uninstalled." -ForegroundColor Green
            }
        }
    }
}
Set-Alias -Name fman -Value fontmanage

