.PHONY: help test lint install uninstall

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

test: ## Run tests
	bats tests/*.bats

lint: ## Lint shell scripts with shellcheck
	shellcheck *.sh shell/*.sh tests/*.sh

install: ## Run the installer
	./install.sh

uninstall: ## Run the uninstaller
	./uninstall.sh
