ARG BASE_IMAGE
FROM ${BASE_IMAGE} as base

ARG SNPTEST_VER
ARG SNPTEST_DIR

# user data provided by the host system via the make file
# without these, the container will fail-safe and be unable to write output
ARG USERNAME
ARG USERID
ARG USERGID

# Put the ARGs into the ENV, so the runtime inherits them
ENV SNPTEST_VER=${SNPTEST_VER}
ENV SNPTEST_DIR=${SNPTEST_DIR}

# Put the user name and ID into the ENV, so the runtime inherits them
ENV USERNAME=${USERNAME:-nouser} \
	USERID=${USERID:-65533} \
	USERGID=${USERGID:-nogroup}

# match the building user. This will allow output only where the building
# user has write permissions
RUN useradd -m -u $USERID -g $USERGID $USERNAME

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
ARG SNPTEST_ARCH="x86_64_dynamic"
ARG SNPTEST_BUILD="2003"
ARG SNPTEST_DIST=${SNPTEST}_CentOS_Linux7.8
ARG SNPTEST_TAR=${SNPTEST_DIST}-${SNPTEST_ARCH}.tgz

RUN wget https://${SNPTEST_URL}/$SNPTEST_TAR && mkdir -p ${SNPTEST_DIR} && \
	tar xvf $SNPTEST_TAR --strip-components=1 -C ${SNPTEST_DIR} && \
	rm $SNPTEST_TAR && \
	ln -s ${SNPTEST_DIR}/${SNPTEST} /usr/local/bin/snptest

# we map the user owning the image so permissions for input/output will work
USER $USERNAME

ENTRYPOINT [ "snptest" ]
