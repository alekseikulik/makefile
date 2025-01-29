# Default.
default: help

.PHONY: help
help: # Show this help
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

timestamp=$(shell date +%s)

PHONY: test
test:
	@terraform -chdir=terraform init && terraform -chdir=terraform validate
	@checkov --quiet --compact --directory .
	@helmfile -e production lint
