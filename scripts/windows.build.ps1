Write-Host "Build the site..." -ForegroundColor Green

hugo --destination public --contentDir _content --theme hugo-brutalist
