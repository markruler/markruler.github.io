Write-Host "Remove all generated files and directories..."

powershell -Command Remove-Item -Force -Recurse `
  posts/ `
  about/ `
  categories/ `
  public/ `
  js/ `
  page/ `
  resources/ `
  scss/ `
  series/ `
  tags/ `
  vendor/ `
  404.html `
  index.html `
  index.xml `
  robots.txt `
  rss.xsl `
  sitemap.xml `
-ErrorAction SilentlyContinue; exit 0
