# This Makefile contains scripts to build ci-helper.
.PHONY: help


help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


build-local: ## Build Docker image and store it locally.
	docker build --rm --build-arg DOCKER_VERSION=$(VERSION) -t juliusleppala/ci-helper:$(VERSION) .


build: ## Build Docker image and push it to Docker Hub.
	docker buildx create --use
	docker buildx build --build-arg DOCKER_VERSION=$(VERSION) --platform linux/amd64,linux/arm64 -t juliusleppala/ci-helper:$(VERSION) --push .