# SPDX-License-Identifier: GPL-2.0

ORG_NAME ?= hihg-um
OS_BASE ?= centos
OS_VER ?= centos7

IMAGE_REPOSITORY ?=

TOOLS := snptest

DOCKER_BUILD_ARGS ?=
DOCKER_TAG ?= $(shell git describe --tags --broken --dirty --all --long \
			| sed "s,heads/,," | sed "s,tags/,,")
DOCKER_IMAGES := $(TOOLS:=\:$(DOCKER_TAG))
SIF_IMAGES := $(TOOLS:=\:$(DOCKER_TAG).sif)

# SNPTEST-specific
SNPTEST_VER ?= snptest_v2.5.6
SNPTEST_ARCH ?= CentOS_Linux7.9.2009-x86_64_static

.PHONY: apptainer_clean apptainer_test \
	docker_clean docker_test docker_release $(TOOLS)

help:
	@echo "Targets: all build clean test release"
	@echo "         docker docker_clean docker_test docker_release"
	@echo "         apptainer apptainer_clean apptainer_test"
	@echo
	@echo "Docker container(s):"
	@for f in $(DOCKER_IMAGES); do \
		printf "\t$$f\n"; \
	done
	@echo
	@echo "Apptainer(s):"
	@for f in $(SIF_IMAGES); do \
		printf "\t$$f\n"; \
	done
	@echo

all: clean build test

build: docker apptainer

clean: apptainer_clean docker_clean

release: docker_release

test: docker_test apptainer_test

# Docker
docker: $(TOOLS)

$(TOOLS):
	@echo "Building Docker container: $@"
	@docker build -t $(ORG_NAME)/$@:$(DOCKER_TAG) \
		$(DOCKER_BUILD_ARGS) \
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		--build-arg SNPTEST_VER=$(SNPTEST_VER) \
		--build-arg SNPTEST_ARCH=$(SNPTEST_ARCH) \
		--build-arg RUN_CMD=$@ \
		.
	$(if $(shell git fetch; git diff @{upstream}),,docker tag \
		$(ORG_NAME)/$@:$(DOCKER_TAG) $(ORG_NAME)/$@:latest)

docker_clean:
	@for f in $(TOOLS); do \
		echo "Cleaning up Docker container: $$f:$(DOCKER_TAG)"; \
		docker rmi -f $(ORG_NAME)/$$f:$(DOCKER_TAG) 2>/dev/null; \
		if [ -z "`git fetch; git diff @{upstream}`" ]; then \
			docker rmi -f $(ORG_NAME)/$$f:latest; \
		fi \
	done

docker_test: 
	@for f in $(DOCKER_IMAGES); do \
		echo "Testing Docker container: $(ORG_NAME)/$$f"; \
		docker run -t \
			-v /etc/passwd:/etc/passwd:ro \
			-v /etc/group:/etc/group:ro \
			--user=$(shell echo `id -u`):$(shell echo `id -g`) \
			$(ORG_NAME)/$$f -help; \
	done

docker_release: $(DOCKER_IMAGES)
	@for f in $^; do \
		docker push $(IMAGE_REPOSITORY)/$(ORG_NAME)/$$f; \
	done

# Apptainer
apptainer: $(SIF_IMAGES)

$(SIF_IMAGES):
	@echo "Building Apptainer: $@"
	@apptainer build $@ docker-daemon:$(ORG_NAME)/$(patsubst %.sif,%,$@)

apptainer_clean:
	@for f in $(SIF_IMAGES); do \
		printf "Cleaning up Apptainer: $$f\n"; \
		rm -f $$f; \
	done

apptainer_test: $(SIF_IMAGES)
	@for f in $^; do \
		echo "Testing Apptainer: $$f"; \
		apptainer run $$f -help; \
	done
