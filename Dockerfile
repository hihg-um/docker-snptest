# This is a typical three-stage docker build.

FROM centos:centos8 as base

# user data provided by the host system via the make file
# without these, the container will fail-safe and be unable to write output
# to any bind-mounted data volumes
ARG USERNAME
ARG USERID
ARG USERGID

# Put the user name and ID into the ENV, so the runtime inherits them
ENV USERNAME=${USERNAME:-nouser} \
	USERID=${USERID:-65533} \
	USERGID=${USERGID:-nogroup}

# match the building user. This will allow output only where the building
# user has write permissions
RUN useradd -m -u $USERID -g $USERGID $USERNAME

# Install OS updates, security fixes and utils, generic app dependencies
RUN yum -y update && yum -y upgrade && \
	yum -y install epel-release && yum repolist && \
	yum -y install gnuplot htslib wget zlib

# This creates the actual container we will run
FROM base AS release

ARG SNPTEST="snptest_v2.5.6"
ARG SNPTEST_ARCH="x86_64_dynamic"
ARG SNPTEST_BUILD="2003"
ARG SNPTEST_DIST=${SNPTEST}_CentOS_Linux7.8
ARG SNPTEST_TAR=${SNPTEST_DIST}-${SNPTEST_ARCH}.tgz
RUN wget http://www.well.ox.ac.uk/~gav/resources/$SNPTEST_TAR && \
	tar xvf $SNPTEST_TAR -C /opt/ && rm $SNPTEST_TAR && \
	chown -R root:users /opt/${SNPTEST_DIST}* && \
	ln -s /opt/${SNPTEST_DIST}.${SNPTEST_BUILD}-${SNPTEST_ARCH}/${SNPTEST} \
		/usr/local/bin/snptest && snptest -help

WORKDIR /runtime
RUN chown -R $USERNAME:$USERGID /runtime

USER $USERNAME

CMD ["snptest"]
