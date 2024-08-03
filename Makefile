init:
	git submodule update --init --recursive
.PHONY: init

clean: clean
	@echo "Remove all generated files and directories..."
	rm -rf posts/ categories/ tags/ about/ page/ scss/ series/ js/ vendor/ resources/ \
		404.html index.html index.xml sitemap.xml rss.xsl robots.txt
.PHONY: clean

build: clean
	@echo "Build the site..."
	@hugo --destination . --contentDir _content --theme hugo-theme-diary
.PHONY: build

deploy:
	@echo "Deploy the site..."
	@./scripts/deploy.sh
.PHONY: deploy

run:
	@echo "Run the site..."
	@./scripts/startup.sh
.PHONY: run
