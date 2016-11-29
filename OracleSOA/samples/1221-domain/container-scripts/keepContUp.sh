#!/bin/sh
#
# Author: swati.mukundan@oracle.com
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
#*************************************************************************
# script is used to keep a container up and running by tailing sample logs.
#*************************************************************************
export vol_name=$vol_name
echo `hostname -I` " " `hostname` > /soavolume/oracle/logs/hostnames.txt
echo "Keeping the container up" >> /$vol_name/oracle/logs/temp.txt
tail -f /$vol_name/oracle/logs/temp.txt

