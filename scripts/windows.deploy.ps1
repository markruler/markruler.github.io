# cd _blog
Write-Host "Deploying updates to GitHub..."
hugo --destination . --contentDir content --theme hugo-theme-diary

git add -A
git commit -m "rebuilding site $(Get-Date) on Windows"
git push origin v2
