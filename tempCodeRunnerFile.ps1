function Move-ConfigFolder {
    $sourcePath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\es"
    $destinationPath = "C:\es"

    if (Test-Path $sourcePath) {
        if (Test-Path $destinationPath) {
            Write-Host "Destination folder exists at $destinationPath. Syncing contents..."
            Get-ChildItem -Path $sourcePath | ForEach-Object {
                $destItem = Join-Path $destinationPath $_.Name
                if (Test-Path $destItem) {
                    Write-Host "Updating existing item: $($_.Name)"
                }
                else {
                    Write-Host "Adding new item: $($_.Name)"
                }
                Copy-Item -Path $_.FullName -Destination $destinationPath -Force -Recurse
            }
        }
        else {
            Write-Host "Creating and populating $destinationPath..."
            New-Item -Path $destinationPath -ItemType Directory
            Get-ChildItem -Path $sourcePath | Copy-Item -Destination $destinationPath -Force -Recurse
        }
        Write-Host "Config folder sync completed successfully"
    }
    else {
        Write-Host "Source folder not found at $sourcePath"
    }
}
Move-ConfigFolder