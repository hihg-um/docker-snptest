# SPDX-License-Identifier: GPL-2.0
ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG SNPTEST_VER
ARG SNPTEST_ARCH
ARG RUN_CMD

# Install OS updates, security fixes and utils, generic app dependencies
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
		ca-certificates curl libcurl3-gnutls \
		less libfile-pushd-perl libhts3 \
		strace wget xz-utils zlib1g

WORKDIR /runtime

ARG SNPTEST_URL="https://www.well.ox.ac.uk/~gav/resources/"
ARG SNPTEST_TAR=${SNPTEST_VER}_${SNPTEST_ARCH}.tgz
ARG SNPTEST_DIR="/opt/bin"

RUN wget ${SNPTEST_URL}/${SNPTEST_TAR} && mkdir -p ${SNPTEST_DIR} && \
        tar xvf $SNPTEST_TAR --strip-components=1 -C ${SNPTEST_DIR} && \
        ln -s "${SNPTEST_DIR}/${SNPTEST_VER}" "${SNPTEST_DIR}/${RUN_CMD}" && \
        rm $SNPTEST_TAR
ENV PATH=${SNPTEST_DIR}:${PATH}

COPY src/${RUN_CMD}.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
