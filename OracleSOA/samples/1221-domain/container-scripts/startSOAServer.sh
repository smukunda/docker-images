#!/bin/sh
#
# Author: swati.mukundan@oracle.com
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
#*************************************************************************
# script is used to start a SOA server.
# Prerequisite: Oracle DB or any other supported db should be up and running.
#
# Following details should be mentioned in soaenv.list
#
#                 vol_name=<volumename>
#                 hostname=<hostname>
#                 adminport=<port number where Admin Server is running>
#                 server=<name of managed server to be started>
#
# vol_name - Name of the volume that is created earlier.
# hostname - Name of the host where all the docker activities are happening.
# adminport - port number where Admin Server is running.
#
#*************************************************************************

export vol_name=$vol_name
export hostname=$hostname
export adminport=$adminport
export server=$server
# Start SOA server
/$vol_name/oracle/user_projects/domains/base_domain/bin/startManagedWebLogic.sh $server "http://"$hostname:$adminport > /$vol_name/oracle/logs/startManagedWebLogic$$.log 2>&1 &
statusfile=/tmp/notifyfifo.$$
mkfifo "${statusfile}" || exit 1
{
    # run tail in the background so that the shell can kill tail when notified that grep has exited
    tail -f /$vol_name/oracle/logs/startManagedWebLogic$$.log &
    # remember tail's PID
    tailpid=$!
    # wait for notification that grep has exited
    read templine <${statusfile}
                        echo ${templine}
    # grep has exited, time to go
    kill "${tailpid}"
} | {
    grep -m 1 "<Notice> <WebLogicServer> <BEA-000360> <The server started in RUNNING mode.>"
    # notify the first pipeline stage that grep is done
        echo "RUNNING"> /$vol_name/oracle/logs/startManagedWebLogic$$.status
        echo "SOA server is running"
    echo >${statusfile}
}
# clean up
rm "${statusfile}"
if [ -f /$vol_name/oracle/logs/startManagedWebLogic$$.status ]; then
echo "SOA server has been started"
fi

#Display the logs
tail -f /$vol_name/oracle/logs/*