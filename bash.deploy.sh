#!/usr/bin/env bash

# _blog/ 수정없이 커밋할 필요가 있을 경우
# ex) README 파일 수정

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin main
