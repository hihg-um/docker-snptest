ORG_NAME ?= hihg-um
PROJECT_NAME ?= docker-snptest

IMAGE_REPOSITORY :=
IMAGE := $(ORG_NAME)/$(PROJECT_NAME):latest

# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS := --progress=plain
SNPTEST_DIR := /opt/snptest

.PHONY: all build clean test tests

all: docker test

tests: test

test: docker
	@docker run -t $(IMAGE) -help > /dev/null

clean:
	@docker rmi $(IMAGE)

docker:
	@docker build -t $(IMAGE) \
		--build-arg SNPTEST_DIR="$(SNPTEST_DIR)" \
		$(DOCKER_BUILD_ARGS) \
	  .

release:
	docker push $(IMAGE_REPOSITORY)/$(IMAGE)
