# This Makefile contains scripts to build ci-helper.
.PHONY: help


help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


build-local: ## Build Docker image and store it locally.
	docker build --rm --build-arg DOCKER_VERSION=$(VERSION) -t juliusleppala/ci-helper:$(VERSION) .


build: ## Build Docker image and push it to Docker Hub.
	docker buildx create --name ci-helper || true
	docker buildx use ci-helper
	docker buildx build \
    	--build-arg DOCKER_VERSION=$(VERSION) \
    	--platform linux/amd64,linux/arm64 \
    	--cache-from=type=registry,ref=juliusleppala/ci-helper:$(VERSION)-cache \
    	--cache-to=type=registry,ref=juliusleppala/ci-helper:$(VERSION)-cache,mode=max \
      	-t juliusleppala/ci-helper:$(VERSION) \
      	--push \
      	.
