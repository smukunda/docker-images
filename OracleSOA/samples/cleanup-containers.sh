#!/bin/sh
#
# Author: swati.mukundan@oracle.com
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
#*************************************************************************
# script is used to start clean up Exited containers that consume space.
#
# The script takes a file name as input, writes the container id of exited
# containers in this file and deletes them one by one.
#
#*************************************************************************

export file=$1
docker ps -a | grep Exited | awk '{print  $1}' > $file

if [[ -s $file ]] ; then
{
echo "Below containers are in "Exited" status and are to be deleted"
cat $1
while IFS='' read -r line || [[ -n "$line" ]];
do {
    echo "Deleting container: $line"
    docker rm -f $line
   }
done < "$1"
}
else
echo "There are no containers in "Exited" status"
fi ;
