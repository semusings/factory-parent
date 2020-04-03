.PHONY: help
.DEFAULT_GOAL := help
_version := $(shell scripts/version.sh)

help:
	@echo "---------------------------------------------------------------------------------------"
	@echo ""
	@echo "				CLI"
	@echo ""
	@echo "---------------------------------------------------------------------------------------"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

build: ## Build the project
	./mvnw clean install -U -P sonar

xdocs: ## Build the documentation
	./mvnw clean verify -U -P docs

##@ Releasing

version: ## Get the current Academy version
	@echo $(_version)

release-clean: ## Cleaning a Release
	./mvnw -s settings.xml clean release:clean

release-rollback: ## Rollback a Release
	./mvnw -s settings.xml clean release:rollback

release-prepare: ## Preparing the Release
	./mvnw -s settings.xml clean release:prepare

release-perform: ## Performing the Release
	@read -p "Sonatype Password: " passwd; \
	./mvnw -s settings.xml clean release:perform -DsonatypeUser=developerbhuwan -DsonatypePassword=$${passwd}

##@ GPG Key

gpg-generate: ## Generate new GPG key
	gpg --full-generate-key
gpg-export: ## Export GPG Key
	cd ${HOME}/.gnupg && \
	gpg --export-secret-keys -o secring.gpg
gpg-publish: ## Publish GPG to keyserver
	gpg -K
	@read -p "Gpg Key Id: " keyId; \
	gpg --send-keys --keyserver keyserver.ubuntu.com $${keyId}