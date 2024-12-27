#function lab {cd "c:\new"}
function edit {cd "C:\Users\Manisk\AppData\Local\nvim"}
Set-Alias -Name gna -Value Get-NetAdapter
function spshell {cd "C:\Users\Manisk\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"}
# Reload the PowerShell profile
function reload-profile {
	& $PROFILE
	Write-Host "Success!"
}
function rel{. $profile}
Set-Alias e explorer.exe
Set-Alias c vscode.exe
Set-Alias -Name cpy -Value Set-Clipboard
Set-Alias -Name dq -Value driverquery

function fst { param($searchString) findstr /i "$searchString" }
# Git Shortcuts
function gs { git status }

function ga { git add . }

function gc { param($m) git commit -m "$m" }

function gp { git push }

function g { __zoxide_z github }

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
#yazi file manager for console 
function fm {yazi }
Set-Alias recon reload-profile

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
Set-Alias -Name su -Value admin

function npedit {notepad++.exe $PROFILE}


function pkill($name) {
    $process = Get-Process -Name $name -ErrorAction SilentlyContinue
    
    if ($process) {
        # Stop the process if found
        Stop-Process -Name $name -Force
        Write-Host "Process '$name' has been terminated."
    } else {
        # Handle the case when the process is not found
        Write-Host "Process '$name' not found."
    }
}

function home {cd "C:\Users\Manisk"}
# Navigation Shortcuts
function docs { Set-Location -Path $HOME\Documents }

function des { Set-Location -Path $HOME\Desktop }

# Quick Access to Editing the Profile
function ep { nvim $PROFILE }
function eueli {nvim "C:\Users\Manisk\AppData\Roaming\ueli\config.json"}
# Simplified Process Management
function k9 { Stop-Process -Name $args[0] }

# Enhanced Listing
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

#Zoxide 
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-Alias -Name cd -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name cdi -Value __zoxide_zi -Option AllScope -Scope Global -Force
#Set-Alias -Name cf -Value __zoxide_zi -Option AllScope -Scope Global -Force

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
    $process = Get-Process -Name $name -ErrorAction SilentlyContinue
    
    if ($process) {
        # Display the main process
        $processInfo = $process | Select-Object CPU, @{Name="Memory(MB)"; Expression={[math]::round($_.WorkingSet / 1MB, 2)}}, Id, SI, ProcessName
        Write-Host "Main Process:" -NoNewline
        Write-Host "`n"  # Ensure the output starts on a new line
        $processInfo

        # Count foreground and background subprocesses
        $subProcesses = Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $process.Id }
        
        $foregroundCount = $subProcesses | Where-Object { $_.Handle -ne 0 } | Measure-Object | Select-Object -ExpandProperty Count
        $backgroundCount = $subProcesses | Where-Object { $_.Handle -eq 0 } | Measure-Object | Select-Object -ExpandProperty Count

        Write-Host "Number of Foreground Processes: $foregroundCount"
        Write-Host "Number of Background Processes: $backgroundCount"
    } else {
        Write-Host "Process '$name' not found."
    }
}

function ReloadProfile {
    . $PROFILE
}

Set-Alias -Name rpro -Value ReloadProfile
# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

function touch($file) { "" | Out-File $file -Encoding ASCII }

#shows path of the commands
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

Set-Alias -Name np -Value Notepad++.exe

# Define the function to set brightness based on a scale of 1 to 10
function Set-Brightness {
    param (
        [int]$Level
    )

    # Ensure the level is between 1 and 10
    if ($Level -lt 1 -or $Level -gt 10) {
        Write-Output "Please enter a level between 1 and 10."
        return
    }

    # Calculate brightness on a 0-100 scale
    $brightnessLevel = ($Level - 1) * 10

    # Get the brightness method and set brightness
    $brightnessMethod = Get-WmiObject -Namespace root/wmi -Class WmiMonitorBrightnessMethods
    $brightnessMethod.WmiSetBrightness(1, $brightnessLevel)

    Write-Output "Brightness set to $brightnessLevel%"
}

# Create an alias for the function
Set-Alias -Name bright -Value Set-Brightness






Set-Alias lvim 'C:\Users\Manisk\.local\bin\lvim.ps1'

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
