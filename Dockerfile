# SPDX-License-Identifier: GPL-2.0
ARG BASE_IMAGE
FROM $BASE_IMAGE

# Install OS updates, security fixes and utils, generic app dependencies
RUN yum -y update && yum -y upgrade && yum -y install epel-release && \
	yum -y install ca-certificates strace wget