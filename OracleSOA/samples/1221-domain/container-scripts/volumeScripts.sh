#!/bin/bash
#
# Author:swati.mukundan@oracle.com
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
#****************************************************************************************************
#This script and moves the binaries from /u01 to the docker volume.
#
#Pre-requisite : Reqad, Write and Execute permissions must be granted on docker volumes for all users
#****************************************************************************************************
export vol_name=$1
echo "Moving all binaries to docker volume"
mv /u01/oracle /$vol_name
echo "Done"