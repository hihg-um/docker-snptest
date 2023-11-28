# SPDX-License-Identifier: GPL-2.0

ORG_NAME ?= hihg-um
PROJECT_NAME ?= snptest
OS_BASE ?= centos
OS_VER ?= centos7

IMAGE_REPOSITORY ?=

GIT_TAG := $(shell git tag)
GIT_REV := $(shell git describe --always --dirty)
DOCKER_TAG ?= $(GIT_TAG)-$(GIT_REV)

TOOLS := snptest
DOCKER_IMAGES := $(TOOLS:=\:$(DOCKER_TAG))
SVF_IMAGES := $(TOOLS:=\:$(DOCKER_TAG).svf)

# SNPTEST-specific
SNPTEST_VER ?= snptest_v2.5.6
SNPTEST_ARCH ?= CentOS_Linux7.9.2009-x86_64_static

.PHONY: clean docker test test_apptainer test_docker $(DOCKER_IMAGES)

help:
	@echo "Targets: all clean test"
	@echo "         docker test_docker release_docker"
	@echo "         apptainer test_apptainer"
	@echo "Docker containers:\n$(DOCKER_IMAGES)"
	@echo
	@echo "Apptainer images:\n$(SVF_IMAGES)"

all: clean docker test_docker apptainer test_apptainer

clean:
	rm -f $(SVF_IMAGES)
	for f in $(TOOLS); do \
		docker rmi -f $(ORG_NAME)/$$f 2>/dev/null; \
	done

test: test_docker test_apptainer

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

test_docker: $(DOCKER_IMAGES)
	for f in $^; do \
		echo "Testing Docker container: $(ORG_NAME)/$$f"; \
		docker run -t \
			-v /etc/passwd:/etc/passwd:ro \
			-v /etc/group:/etc/group:ro \
			--user=$(shell echo `id -u`):$(shell echo `id -g`) \
			$(ORG_NAME)/$$f -help; \
	done

release_docker: $(DOCKER_IMAGES)
	docker push $(IMAGE_REPOSITORY)/$(ORG_NAME)/$@

$(SVF_IMAGES):
	@echo "Building Apptainer $@"
	apptainer build $@ docker-daemon:$(ORG_NAME)/$(patsubst %.svf,%,$@)

apptainer: $(SVF_IMAGES)

test_apptainer: $(SVF_IMAGES)
	for f in $^; do \
		echo "Testing Apptainer image: $$f"; \
		apptainer run $$f -help; \
	done
