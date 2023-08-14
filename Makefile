# SPDX-License-Identifier: GPL-2.0

ORG_NAME := hihg-um
OS_BASE ?= ubuntu
OS_VER ?= 22.04

IMAGE_REPOSITORY :=
GIT_TAG := $(shell git tag)
GIT_REV := $(shell git describe --always --dirty)
DOCKER_TAG ?= $(GIT_TAG)-$(GIT_REV)

# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS := --progress=plain

TOOLS := snptest
DOCKER_IMAGES := $(TOOLS:=\:$(DOCKER_TAG))
SVF_IMAGES := $(TOOLS:=\:$(DOCKER_TAG).svf)

# SNPTEST-specific
SNPTEST_VER := 2.5.6

.PHONY: clean docker test test_apptainer test_docker $(DOCKER_IMAGES)

help:
	@echo "Targets are docker test_docker release_docker apptainer test_apptainer"
	@echo "Docker: $(DOCKER_IMAGES) Apptainer: $(SVF_IMAGES)"

all: docker test_docker apptainer test_apptainer

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
		--build-arg RUN_CMD=$@ \
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		--build-arg SNPTEST_VER=$(SNPTEST_VER) \
		--build-arg SNPTEST_DIR="/opt/$($@)" \
		.

docker: $(TOOLS)

test_docker: $(DOCKER_IMAGES)
	for f in $^; do \
		echo "Testing docker image: $(ORG_NAME)/$$f"; \
		docker run -t --user $(id -u):$(id -g) -v /mnt:/mnt \
			$(ORG_NAME)/$$f --help; \
	done

release_docker: $(DOCKER_IMAGES)
	@docker push $(IMAGE_REPOSITORY)/$(ORG_NAME)/$@

$(SVF_IMAGES):
	@echo "Building $@"
	apptainer build $@ docker-daemon:$(ORG_NAME)/$(patsubst %.svf,%,$@)

apptainer: $(SVF_IMAGES)

test_apptainer: $(SVF_IMAGES)
	for f in $^; do \
		echo "Testing apptainer image: $$f"; \
		apptainer run $$f --help; \
	done
