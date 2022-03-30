ORG_NAME := hihg-um
PROJECT_NAME ?= snptest
SNPTEST_VER ?= 2.5.6
OS_BASE ?= ubuntu
OS_VER ?= 22.04

IMAGE_REPOSITORY :=
IMAGE := $(ORG_NAME)/$(PROJECT_NAME)-$(SNPTEST_VER):latest

# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS := --progress=plain

SNPTEST_DIR := /opt/$(PROJECT_NAME)

.PHONY: all build clean test tests

all: docker test

test: docker
	@docker run -t $(IMAGE) snptest -help > /dev/null

tests: test

clean:
	@docker rmi $(IMAGE)

docker:
	@docker build -t $(IMAGE) \
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		--build-arg SNPTEST_VER=$(SNPTEST_VER) \
		--build-arg SNPTEST_DIR="$(SNPTEST_DIR)" \
		$(DOCKER_BUILD_ARGS) \
	  .

release:
	docker push $(IMAGE_REPOSITORY)/$(IMAGE)
