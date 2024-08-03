SHELL := bash
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

init:
	git submodule update --init --recursive
.PHONY: init

clean: clean
	@echo "Remove all generated files and directories..."
	rm -rf posts/ categories/ tags/ about/ page/ scss/ series/ js/ vendor/ resources/ \
		404.html index.html index.xml sitemap.xml rss.xsl robots.txt
.PHONY: clean

build: clean
	@printf "\033[38;5;45mBuild the site...\033[38;5;15m\n"
	hugo --destination . --contentDir _content --theme hugo-theme-diary
.PHONY: build

deploy: build
	git add -A
	@msg="rebuilding site $(shell date '+%Y-%m-%dT%H:%M:%S %Z%z') on Unix-like system"; \
	echo "$$msg"; \
	git commit -m "$$msg"
	@printf "\033[38;5;46mDeploying updates to GitHub...\033[38;5;15m\n"
	@git push origin $(BRANCH)
	@printf "\033[38;5;198mCOMPLETE! \033[38;5;15m\n"
.PHONY: deploy

run:
	@echo "Run the site..."
	hugo server --contentDir _content --theme hugo-theme-diary
.PHONY: run
