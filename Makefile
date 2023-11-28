# SPDX-License-Identifier: GPL-2.0

ORG_NAME ?= hihg-um
PROJECT_NAME ?= snptest
OS_BASE ?= ubuntu
OS_VER ?= 22.04

IMAGE_REPOSITORY ?=

DOCKER_TAG := $(shell git describe --tags --abbrev=0 --dirty)

TOOLS := snptest
DOCKER_IMAGES := $(TOOLS:=\:$(DOCKER_TAG))
SVF_IMAGES := $(TOOLS:=\:$(DOCKER_TAG).svf)

# SNPTEST-specific
SNPTEST_VER ?= snptest_v2.5.6
SNPTEST_ARCH ?= CentOS_Linux7.9.2009-x86_64_static

.PHONY: clean docker test apptainer_test docker_test docker_release $(DOCKER_IMAGES)

help:
	@echo "Targets: all clean test"
	@echo "         docker docker_test docker_release"
	@echo "         apptainer apptainer_test"
	@echo "Docker containers:\n$(DOCKER_IMAGES)"
	@echo
	@echo "Apptainer images:\n$(SVF_IMAGES)"

all: clean docker docker_test apptainer apptainer_test

clean:
	rm -f $(SVF_IMAGES)
	for f in $(TOOLS); do \
		docker rmi -f $(ORG_NAME)/$$f 2>/dev/null; \
	done

test: docker_test apptainer_test

$(TOOLS):
	@echo "Building Docker container $@"
	docker build -t $(ORG_NAME)/$@:$(DOCKER_TAG) \
		$(DOCKER_BUILD_ARGS) \
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		--build-arg SNPTEST_VER=$(SNPTEST_VER) \
		--build-arg SNPTEST_ARCH=$(SNPTEST_ARCH) \
		--build-arg RUN_CMD=$@ \
		.

docker: $(TOOLS)

docker_test: $(DOCKER_IMAGES)
	for f in $^; do \
		echo "Testing Docker container: $(ORG_NAME)/$$f"; \
		docker run -t \
			-v /etc/passwd:/etc/passwd:ro \
			-v /etc/group:/etc/group:ro \
			--user=$(shell echo `id -u`):$(shell echo `id -g`) \
			$(ORG_NAME)/$$f -help; \
	done

docker_release: $(DOCKER_IMAGES)
	docker push $(IMAGE_REPOSITORY)/$(ORG_NAME)/$@

$(SVF_IMAGES):
	@echo "Building Apptainer $@"
	apptainer build $@ docker-daemon:$(ORG_NAME)/$(patsubst %.svf,%,$@)

apptainer: $(SVF_IMAGES)

apptainer_test: $(SVF_IMAGES)
	for f in $^; do \
		echo "Testing Apptainer image: $$f"; \
		apptainer run $$f -help; \
	done
