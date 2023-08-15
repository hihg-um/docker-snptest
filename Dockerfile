# SPDX-License-Identifier: GPL-2.0
ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG SNPTEST_VER
ARG SNPTEST_ARCH
ARG RUN_CMD

# Install OS updates, security fixes and utils, generic app dependencies
RUN yum -y update && yum -y upgrade && yum -y install epel-release && \
	yum -y install gnuplot htslib wget zlib

WORKDIR /runtime

ARG SNPTEST_URL="https://www.well.ox.ac.uk/~gav/resources/"
ARG SNPTEST_TAR=${SNPTEST_VER}_${SNPTEST_ARCH}.tgz
ARG SNPTEST_DIR="/usr/local/bin"

RUN wget ${SNPTEST_URL}/$SNPTEST_TAR && \
	tar xvf $SNPTEST_TAR --strip-components=1 -C ${SNPTEST_DIR} && \
	ln -s "${SNPTEST_DIR}/${SNPTEST_VER}" "${SNPTEST_DIR}/${RUN_CMD}" && \
	rm $SNPTEST_TAR

ENV PATH=${PATH}:${SNPTEST_DIR}
# Create an entrypoint for the binary
RUN echo "#!/bin/bash" > /entrypoint.sh && \
	echo "$RUN_CMD \$@" >> /entrypoint.sh && \
	chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
