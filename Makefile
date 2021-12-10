ORG_NAME := genomics
PROJECT_NAME ?= docker-snptest

USER ?= `whoami`
USERID ?= `id -u`
USERGID := `id -g`

IMAGE_REPOSITORY := $(USER)/$(ORG_NAME)/$(PROJECT_NAME):latest

# Use this for debugging builds. Turn off for a more slick build log
# DOCKER_BUILD_ARGS := --progress=plain

.PHONY: all build clean test tests

all: docker test
tests: test

test:

clean:
	@docker rmi $(IMAGE_REPOSITORY)

docker:
	@docker build -t $(IMAGE_REPOSITORY) \
		--build-arg USERNAME=$(USER) \
		--build-arg USERID=$(USERID) \
		--build-arg USERGID=$(USERGID) \
		$(DOCKER_BUILD_ARGS) \
	  .

release:
	docker push $(IMAGE_REPOSITORY)
