SHELL := bash
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

# ANSI Escape Code - Color
# https://en.wikipedia.org/wiki/ANSI_escape_code#colors

all:
	@echo "Usage: make [init|clean|build|deploy|run]"
.PHONY: all

init:
	git submodule update --init --recursive
.PHONY: init

clean:
	@echo "Remove all generated files and directories..."
	rm -rf posts/ \
		about/ \
		categories/ \
		public/ \
		js/ \
		page/ \
		resources/ \
		scss/ \
		series/ \
		tags/ \
		vendor/ \
		404.html \
		index.html \
		index.xml \
		robots.txt \
		rss.xsl \
		sitemap.xml
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
	hugo server --contentDir _content
.PHONY: run
