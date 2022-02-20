ORG_NAME := um
PROJECT_NAME ?= docker-snptest

USER ?= `whoami`
GID ?= users

IMAGE_REPOSITORY :=
IMAGE := $(USER)/$(ORG_NAME)/$(PROJECT_NAME):latest

# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS := --progress=plain

SNPTEST_DIR := /opt/snptest

.PHONY: all build clean test tests

all: docker test

test: docker
	@docker run -t $(IMAGE) snptest -help > /dev/null

tests: test

clean:
	@docker rmi $(IMAGE)

docker:
	@docker build -t $(IMAGE) \
		--build-arg GROUP=$(GID) \
		--build-arg SNPTEST_DIR="$(SNPTEST_DIR)" \
		$(DOCKER_BUILD_ARGS) \
	  .

release:
	docker push $(IMAGE_REPOSITORY)/$(IMAGE)
