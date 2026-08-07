Write-Host "Remove all generated files and directories..." -ForegroundColor Cyan

Remove-Item -Force -Recurse -ErrorAction SilentlyContinue `
  "public/", `
  "resources/", `
  ".hugo_build.lock"
