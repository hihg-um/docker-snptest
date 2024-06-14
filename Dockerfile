# SPDX-License-Identifier: GPL-2.0
ARG BASE
FROM $BASE

# build-args
ARG BASE
ARG GIT_REPO
ARG GIT_TAG
ARG GIT_REV
ARG BUILD_REPO
ARG BUILD_TIME

# Install OS updates, security fixes and utils, generic app dependencies
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
		ca-certificates curl libcurl3-gnutls \
		less libfile-pushd-perl libhts3 \
		strace wget xz-utils zlib1g

LABEL org.opencontainers.image.authors="kms309@miami.edu, sxd1425@miami.edu"
LABEL org.opencontainers.image.base.digest=""
LABEL org.opencontainers.image.base.name="$BASE"
LABEL org.opencontainers.image.created="$BUILD_TIME"
LABEL org.opencontainers.image.description="Base image for SNPtest"
LABEL org.opencontainers.image.licenses="GPL-2.0"
LABEL org.opencontainers.image.ref.name="Utilities"
LABEL org.opencontainers.image.revision="${GIT_REV}"
LABEL org.opencontainers.image.source="https://${GIT_REPO}"
LABEL org.opencontainers.image.title="Dockerized Utilities"
LABEL org.opencontainers.image.url="${BUILD_REPO}"
LABEL org.opencontainers.image.vendor="The Hussman Institute for Human Genomics, The University of Miami Miller School of Medicine"
LABEL org.opencontainers.image.version="${GIT_TAG}"
