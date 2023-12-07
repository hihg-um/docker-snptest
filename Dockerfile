# SPDX-License-Identifier: GPL-2.0
ARG BASE_IMAGE
FROM $BASE_IMAGE

LABEL org.opencontainers.image.description="base image for SNPtest"

# Install OS updates, security fixes and utils, generic app dependencies
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
		ca-certificates curl libcurl3-gnutls \
		less libfile-pushd-perl libhts3 \
		strace wget xz-utils zlib1g
