# SPDX-License-Identifier: GPL-2.0

ARG BASE_IMAGE
FROM ${BASE_IMAGE} as base

ARG SNPTEST_VER
ARG SNPTEST_DIR

# Put the ARgS into the ENV, so the runtime inherits them
ENV SNPTEST_VER=${SNPTEST_VER}
ENV SNPTEST_DIR=${SNPTEST_DIR}

# Install OS updates, security fixes and utils, generic app dependencies
# htslib is libhts3 in Ubuntu see https://github.com/samtools/htslib/
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
		ca-certificates \
		dirmngr \
		ghostscript gnuplot \
		less libfile-pushd-perl libhts3 \
		software-properties-common \
		strace wget xz-utils zlib1g

# This creates the actual container we will run
FROM base AS release

# these args may need to be abstracted for a more generic deployment

WORKDIR /runtime

ARG SNPTEST_URL="www.well.ox.ac.uk/~gav/resources/"
ARG SNPTEST="snptest_v${SNPTEST_VER}"
ARG SNPTEST_ARCH="x86_64_static"
ARG SNPTEST_BUILD=""
ARG SNPTEST_DIST=${SNPTEST}_linux
ARG SNPTEST_TAR=${SNPTEST_DIST}_${SNPTEST_ARCH}.tgz
RUN wget https://${SNPTEST_URL}/$SNPTEST_TAR && mkdir -p ${SNPTEST_DIR} && \
	tar xvf $SNPTEST_TAR --strip-components=1 -C ${SNPTEST_DIR} && \
	rm $SNPTEST_TAR && \
	ln -s ${SNPTEST_DIR}/${SNPTEST} /usr/local/bin/snptest

ENTRYPOINT [ "snptest" ]
