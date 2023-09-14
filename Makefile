# SPDX-License-Identifier: GPL-2.0

ORG_NAME ?= hihg-um
PROJECT_NAME ?= docker-snptest
SNPTEST_VER ?= 2.5.6
OS_BASE ?= centos
OS_VER ?= centos8

USER ?= `whoami`
USERID := `id -u`
USERGID := `id -g`

IMAGE_REPOSITORY :=
IMAGE := $(ORG_NAME)/$(PROJECT_NAME):latest

# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS :=
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
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		--build-arg SNPTEST_DIR="$(SNPTEST_DIR)" \
		$(DOCKER_BUILD_ARGS) \
	  .

release:
	docker push $(IMAGE_REPOSITORY)/$(IMAGE)
