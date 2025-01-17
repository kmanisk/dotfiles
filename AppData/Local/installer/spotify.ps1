$confirmation = Read-Host "Do you want to continue? (y/n)"
if ($confirmation -eq 'y') {
    iex "& { $(iwr -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -new_theme"
} else {
    Write-Host "Operation canceled."
}

# Wait for 5 seconds before closing the window
Start-Sleep -Seconds 5
