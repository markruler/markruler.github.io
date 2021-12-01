# _blog/ 수정없이 커밋할 필요가 있을 경우
# ex) README 파일 수정
# Add changes to git.
git add -A

# Commit changes.
$date=Get-Date
$msg="rebuilding site $date"
if ($msg) {
  write-host("`$msg is $msg")
  git commit -m "$msg"
  # Push source and build repos.
  git push origin main
} else {
  write-host("`$msg is `$null")
}
