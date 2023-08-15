# SPDX-License-Identifier: GPL-2.0
ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG RUN_CMD
ARG SNPTEST_VER

# Install OS updates, security fixes and utils, generic app dependencies
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
		ca-certificates curl libcurl3-gnutls \
		less libfile-pushd-perl libhts3 \
		strace wget xz-utils zlib1g

# analytics package target - we want a new layer here, since different
# dependencies will have to be installed, sharing the common base above

ARG SNPTEST_URL="www.well.ox.ac.uk/~gav/resources/"
ARG SNPTEST="snptest_v${SNPTEST_VER}"
ARG SNPTEST_ARCH="x86_64_dynamic"
ARG SNPTEST_BUILD="2003"
ARG SNPTEST_DIST=${SNPTEST}_CentOS_Linux7.8
ARG SNPTEST_TAR=${SNPTEST_DIST}-${SNPTEST_ARCH}.tgz
ARG SNPTEST_DIR="/usr/local/bin"

RUN wget https://${SNPTEST_URL}/$SNPTEST_TAR && \
	tar xvf $SNPTEST_TAR --strip-components=1 -C ${SNPTEST_DIR} && \
	ln -s ${SNPTEST_DIR}/${SNPTEST} "${SNPTEST_DIR}/${RUN_CMD}" && \
	rm $SNPTEST_TAR

ENV PATH=${PATH}:${SNPTEST_DIR}
# Create an entrypoint for the binary
RUN echo "#!/bin/bash\n$RUN_CMD \$@" > /entrypoint.sh && \
	chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
