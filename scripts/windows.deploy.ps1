# cd _blog
Write-Host "Deploying updates to GitHub..."
# hugo --destination . --contentDir _content --theme hugo-theme-diary
make build

git add -A
git commit -m "rebuilding site $(Get-Date) on Windows"
git push origin v2
