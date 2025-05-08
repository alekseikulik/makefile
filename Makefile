# Variables
TAG := $(shell git rev-parse --short HEAD)
timestamp=$(shell date +%s)

# Default.
default: help

.PHONY: help
help: # Show this help
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

PHONY: test
test: # Run tests
	@echo "--> Tests started at $(shell date)"
	@terraform -chdir=terraform init && terraform -chdir=terraform validate
	@checkov --quiet --compact --directory .
	@helmfile -e production lint
	@echo "--> Tests completed at $(shell date)"

PHONY: tf-module-doc
tf-module-doc: # Generate Terraform module documentation locally
	@terraform-docs markdown table --output-file README.md --output-mode inject ./terraform

.PHONY: build
build: # Build the Docker image
	@echo "Building Docker image..."
	@echo "Tagging image with commit hash: $(TAG)"
	docker build -t actions-runner-custom:$(TAG) .

.PHONY: push
push: # Push the Docker image to the Google Artifact Registry
	@echo "Pushing Docker image to Google Artifact Registry..."
	@echo "Tagging image with commit hash: $(TAG)"
	@echo "Pushing image to registry/actions-runner-custom:$(TAG)"
	docker tag actions-runner-custom:$(TAG) registry/actions-runner-custom:$(TAG)
	docker push registry/actions-runner-custom:$(TAG)
