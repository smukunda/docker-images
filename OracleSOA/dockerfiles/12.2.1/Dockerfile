# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle SOA 12.2.1
#
# Base image of this dockerfile is oracle weblogic 12.2.1 infrastructure docker image.
#
# Pre-requisite to build oracle soa12.2.1 image is to have
# oracle weblogic 12.2.1 infrastructure docker image
#
# To build oracle weblogic 12.2.1 docker image, kindly refer below link
# https://github.com/oracle/docker/tree/master/OracleWebLogic
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) fmw_12.2.1.0.0_soa_Disk1_1of1.zip
#   Download the production distribution for Oracle SOA Suite from the Oracle Software Delivery Cloud
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Make sure that oracle weblogic 12.2.1 infrastructure image is available
# Run:
#      $ docker build -t oracle/soa:12.2.1 .
#
# IMPORTANT
# ---------
# The resulting image of this Dockerfile DOES NOT contain a Domain.
# For that, look into the folder 'samples' for an example on how
# to create a domain using the same install image.
#
# You can go into 'samples/1221-domain' after building the install image
# and create a dummy SOA domain image from oracle/soa:12.2.1, with scripts to create a domain.
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
FROM oracle/weblogic:12.2.1-infrastructure
#
# Maintainer
# ----------
MAINTAINER Swati Mukundan <swati.mukundan@oracle.com>
#
#
# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
USER root
ENV FMW_PKG=fmw_12.2.1.0.0_soa_Disk1_1of1.zip \
    FMW_JAR=fmw_12.2.1.0.0_soa.jar \
    ORACLE_HOME=/u01/oracle \
    USER_MEM_ARGS="-Djava.security.egd=file:/dev/./urandom" \
    PATH=$PATH:$JAVA_HOME/bin:$ORACLE_HOME/oracle_common/common/bin
#
#
# Copy files and packages for install
# -----------------------------------
COPY $FMW_PKG install.file oraInst.loc /u01/
#
#
# Install OL7 required packages. Refer FMW 12.2.1 System requirements guide for complete list of packages
# Change the open file limits and kernel parameters that need changing
# Setup filesystem and oracle user
# Unzip SOA installer
# Go to /u01 as user 'oracle' to proceed with SOA installation
#---------------------------------------------------------------------------------------------------------
# Proxy needs to be set before running yum in /etc/yum.conf
RUN yum install -y \
        unzip tar nfs-utils binutils compat-libcap1 compat-libstdc++ \
        gcc gcc-c++ glibc glibc-devel libaio libaio-devel libgcc \
        libstdc++ libstdc++-devel ksh make ocfs2-tools sysstat iputils sudo && \
        chmod a+xr /u01 && \
        chmod a+s `which ping` && \
        cd /u01 && $JAVA_HOME/bin/jar xf /u01/$FMW_PKG && cd - && \
        su -c "$JAVA_HOME/bin/java -jar /u01/$FMW_JAR -silent -responseFile /u01/install.file -invPtrLoc /u01/oraInst.loc -jreLoc $JAVA_HOME -ignoreSysPrereqs -force -novalidation ORACLE_HOME=$ORACLE_HOME INSTALL_TYPE=\"SOA Suite\"" - oracle && \
       chown oracle:oracle -R /u01 && \
       rm /u01/$FMW_JAR /u01/$FMW_PKG /u01/oraInst.loc /u01/install.file
#
#
#
# Define default command to start bash.
#CMD ["/u01/oracle/user_projects/domains/base_domain/bin/startWebLogic.sh"]
CMD ["bash"]