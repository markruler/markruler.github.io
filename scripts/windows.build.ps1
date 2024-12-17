Write-Host "Build the site..." -ForegroundColor Green

hugo --destination . --contentDir _content --theme hugo-theme-diary
