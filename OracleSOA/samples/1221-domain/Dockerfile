# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle SOA 12.2.1 domain image
#
# Base image of this dockerfile is oracle soa 12.2.1 docker image.
#
# Pre-requisite to build oracle soa12.2.1 image is to have
# oracle soa 12.2.1 docker image
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
#   None, as this is a dummy soa domain image i.e., SOA install image with the scripts to configure SOA domain.
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Make sure that oracle SOA 12.2.1 image is available
# Run:
#      $ docker build -t oracle/soa-domain:12.2.1 .
#
# IMPORTANT
# ---------
# The resulting image of this Dockerfile DOES NOT contain SOA domain, but has scripts to create SOA Domain.
#
# For that, look into the folder 'samples' for an example on how
# to create a domain using the same install image.
#
#
# Create a docker volume to be shared across all the containers.
#
# Then create a volume container using this dummy SOA domain image and share the binaries and scripts in a docker volume.
# Create a another container out of the same image and call configureSOAdomain.sh to configure soa domain
# and start the Admin Server. Further, create a new container, again from the same image and call startSOAServer.sh
# to start the default SOA Server in the domain. All these containers will be sharing the same docker volume.
#
# For example:
#
#   $ cd samples/1221-domain
#   $ ./buildDockerImage.sh -v 12.2.1 -s
#   $ docker volume create --name soavolume
#   $ docker run -it -v soavolume:/soavolume --name volcontainer oracle/soa-domain:12.2.1 volumeScripts.sh soavolume
#   $ docker run -i -t  -p 7001:7001 -v soavolume:/soavolume --name wlscontainer --env-file ./wlsenv.list oracle/soa-domain:12.2.1 configureSOAdomain.sh
#   $ docker run -i -t  -p 8001:8001 -v soavolume:/soavolume --name soacontainer  --env-file ./soaenv.list oracle/soa-domain:12.2.1 startSOAServer.sh
#
# Pull base image
# ---------------
FROM oracle/soa:12.2.1
# Maintainer
# ----------
MAINTAINER Swati Mukundan <swati.mukundan@oracle.com>
#
#
# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
USER root
ENV ORACLE_HOME=/u01/oracle \
    USER_MEM_ARGS="-Djava.security.egd=file:/dev/./urandom" \
    SOA_PORT=8001 \
    ADMIN_PORT=7001 \
    SOA_SSL_PORT=8002 \
#   CONNECTION_STRING=<HostName>:<Port#>:<SID> \
    DOMAIN_NAME=base_domain \
    PATH=$PATH:$JAVA_HOME/bin:$ORACLE_HOME/oracle_common/common/bin:$ORACLE_HOME/container-scripts
#
#
# Expose all Ports
#-----------------
EXPOSE $SOA_SSL_PORT $SOA_PORT $ADMIN_PORT
#
#
# Create necessary dir structure to keep soa domain files and copy the scripts
# ---------------------------------------------------------------------------------------
USER oracle
RUN mkdir /u01/oracle/container-scripts/ /u01/oracle/logs
COPY container-scripts/* /u01/oracle/container-scripts/
USER root
RUN chmod a+xr /u01/oracle/container-scripts/*.*
USER oracle
WORKDIR $ORACLE_HOME/container-scripts
#
# Define default command to start bash.
CMD ["bash"]