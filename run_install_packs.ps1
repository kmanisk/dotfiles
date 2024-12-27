# Construct the dynamic path
$scriptPath = Join-Path -Path "$HOME\.local\share\chezmoi\AppData\Local\run_scripts" `
    -ChildPath "literal_run_install-packages-windows.ps1"

#write-host $scriptPath
# excepted output : C:\Users\Manisk\.local\share\chezmoi\AppData\Local\run_scripts
# produced output
#C:\Users\Manisk\.local\share\chezmoi\AppData\Local\run_scripts\literal_run_install-packages-windows.ps1
# Call the script
& $scriptPath
