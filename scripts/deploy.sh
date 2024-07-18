#!/usr/bin/env bash

push_branch="v2"

# https://gohugo.io/hosting-and-deployment/hosting-on-github/#put-it-into-a-script

# git init
# git submodule add https://github.com/AmazingRise/hugo-theme-diary.git themes/diary
# git submodule update # git submodule update --remote --merge
# git remote add hub https://github.com/markruler/markruler.github.io.git

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Build the project.
hugo --destination . --contentDir content --theme hugo-theme-diary

# git add .
git add -A

msg="rebuilding site $(date) on Unix-like system"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

git push origin $push_branch
