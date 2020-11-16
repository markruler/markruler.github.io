# Add changes to git.
git add -A

# Commit changes.
$date=Get-Date
$msg="rebuilding site $date"
if ($msg) {
  write-host("`$msg is $msg")
  git commit -m "$msg"
  # Push source and build repos.
  git push origin master
} else {
  write-host("`$msg is `$null")
}
