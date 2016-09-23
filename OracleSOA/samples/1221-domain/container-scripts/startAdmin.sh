#!/bin/sh
#
# Author: swati.mukundan@oracle.com
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
#*************************************************************************
# script is used to start a WebLogic server.
#*************************************************************************

export vol_name=$1
# Start Admin server
/$vol_name/oracle/user_projects/domains/base_domain/bin/startWebLogic.sh > /$vol_name/oracle/logs/startWebLogic$$.log 2>&1 &
statusfile=/tmp/notifyfifo.$$
mkfifo "${statusfile}" || exit 1
{
    # run tail in the background so that the shell can kill tail when notified that grep has exited
    tail -f /$vol_name/oracle/logs/startWebLogic$$.log &
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
        echo "RUNNING"> /$vol_name/oracle/logs/startWebLogic$$.status
        echo "Admin server is running"
    echo >${statusfile}
}
# clean up
rm "${statusfile}"
if [ -f /$vol_name/oracle/logs/startWebLogic$$.status ]; then
echo "Admin server running, ready to start SOA server"
fi

#Display the logs
tail -f /$vol_name/oracle/logs/*