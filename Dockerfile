# SPDX-License-Identifier: GPL-2.0
ARG BASE_IMAGE
FROM ${BASE_IMAGE} 

ARG RUN_CMD
ARG SNPTEST_VER
ARG SNPTEST_DIR

# Install OS updates, security fixes and utils, generic app dependencies
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
		ca-certificates curl\
		less libfile-pushd-perl libhts3 \
		strace wget xz-utils zlib1g

ARG INST=/usr/local/bin

WORKDIR /app

ARG SNPTEST_URL="www.well.ox.ac.uk/~gav/resources/"
ARG SNPTEST="snptest_v${SNPTEST_VER}"
ARG SNPTEST_ARCH="x86_64_dynamic"
ARG SNPTEST_BUILD="2003"
ARG SNPTEST_DIST=${SNPTEST}_CentOS_Linux7.8
ARG SNPTEST_TAR=${SNPTEST_DIST}-${SNPTEST_ARCH}.tgz

RUN wget https://${SNPTEST_URL}/$SNPTEST_TAR && mkdir -p ${SNPTEST_DIR} && \
	tar xvf $SNPTEST_TAR --strip-components=1 -C ${SNPTEST_DIR} && \
	rm $SNPTEST_TAR && \
	ln -s ${SNPTEST_DIR}/${SNPTEST} "/usr/local/bin/$RUN_CMD" 

ENV PATH=${PATH}:${SNPTEST_DIR}
ENTRYPOINT [ $RUN_CMD ]
