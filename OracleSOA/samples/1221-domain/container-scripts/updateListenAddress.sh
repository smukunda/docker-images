#!/bin/sh
#
# Author: swati.mukundan@oracle.com
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
#*************************************************************************
# script is used to update the listen address of SOA server.
# Prerequisite: Oracle DB or any other supported db should be up and running.
#
# Following details should be mentioned in soaenv.list
#
#                 vol_name=<volumename>
#                 hostname=<hostname>
#                 adminport=<port number where Admin Server is running>
#                 server=<name of SOA managed server>
#
# vol_name - Name of the volume that is created earlier.
# hostname - Name of the host where all the docker activities are happening.
# adminport - port number where Admin Server is running.
# server - Name of SOA managed server
#
#*************************************************************************

export vol_name=$vol_name
export server=$server
export soa_host=`hostname -I`
/$vol_name/oracle/oracle_common/common/bin/wlst.sh -skipWLSModuleScanning /$vol_name/oracle/container-scripts/update_listenaddress.py $vol_name $soa_host $server
#
# Keeping the container up
#=========================
/$vol_name/oracle/container-scripts/keepContUp.sh $vol_name

