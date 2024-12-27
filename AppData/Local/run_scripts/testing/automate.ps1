Write-Host "Starting automation"
Set-Location -Path "$HOME\.local\share\chezmoi"
git add .
$userinp = Read-Host -Prompt "Enter commit message"
git commit -m "$userinp"
git push -u origin master

