FROM ubuntu:22.04 as base

# group data provided by the host system via the make file
# without the group, the container will fail-safe and be unable to write output
ARG SNPTEST_DIR

# Put the user name and ID into the ENV, so the runtime inherits them
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
ARG SNPTEST="snptest_v2.5.6"
ARG SNPTEST_ARCH="x86_64_dynamic"
ARG SNPTEST_BUILD="2003"
ARG SNPTEST_DIST=${SNPTEST}_CentOS_Linux7.8
ARG SNPTEST_TAR=${SNPTEST_DIST}-${SNPTEST_ARCH}.tgz
RUN wget https://${SNPTEST_URL}/$SNPTEST_TAR && mkdir -p ${SNPTEST_DIR} && \
	tar xvf $SNPTEST_TAR --strip-components=1 -C ${SNPTEST_DIR} && \
	rm $SNPTEST_TAR && \
	ln -s ${SNPTEST_DIR}/${SNPTEST} /usr/local/bin/snptest

ENTRYPOINT [ "snptest" ]
