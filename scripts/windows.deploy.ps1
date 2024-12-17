Write-Host "Deploying updates to GitHub..." -ForegroundColor Magenta

git add -A
git commit -m "rebuilding site $(Get-Date) on Windows"
git push origin HEAD
