#!/bin/bash
#
# Author:swati.mukundan@oracle.com
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
#********************************************************************************************
#This script will configure Oracle SOA suite, a sample domain - basedomain - will be created.
#
#Prerequisite: Oracle DB or any other supported db should be up and running.
#
# Following details should be mentioned in wlsenv.list
#
#         CONNECTION_STRING=<database_host_name>:port#:SID
#         RCUPREFIX=<RCU_Prefix>
#         DB_PASSWORD=<database_password>
#         ADMIN_PASSWORD=<admin_password>
#         hostname=<hostname>
#         vol_name=<volumename>
#         admin_host=<host name for admin container>
#         soa_host=<host name for soa container>
#
# CONNECTION_STRING - Connection details to your database should be specified in wlsenv.list. For example, in case of Oracle DB, connection string will be of the format dbhost:dbport:dbsid. This db should be up and running.
#
# RCUPREFIX - Schema prefix used to create necessary schemas should be specified in wlsenv.list
#
# DB_PASSWORD - Password to connect to the db mentioned above.
#
# ADMIN_PASSWORD - Password for the Admin Server and SOA Server.
#
# hostname - Name of the host where all the docker activities are happening.
#
# vol_name - Name of the volume that is created earlier.
#
# admin_host - Host name of the container where the Admin Server is running.
#
# soa_host - Host name of the container where the SOA Server is running.
#
#********************************************************************************************
echo "CONNECTION_STRING=${CONNECTION_STRING:?"Please set CONNECTION_STRING"}"
echo "RCUPREFIX=${RCUPREFIX:?"Please set RCUPREFIX"}"
echo "DB_PASSWORD=${DB_PASSWORD:?"Please set DB_PASSWORD"}"
echo "ADMIN_PASSWORD=${ADMIN_PASSWORD:?"Please set ADMIN_PASSWORD"}"
export CONNECTION_STRING=$CONNECTION_STRING
export RCUPREFIX=$RCUPREFIX
export ADMIN_PASSWORD=$ADMIN_PASSWORD
export DB_PASSWORD=$DB_PASSWORD
export jdbc_url="jdbc:oracle:thin:@"$CONNECTION_STRING
export vol_name=$vol_name
export admin_host=$admin_host
export soa_host=$soa_host
echo -e $DB_PASSWORD"\n"$ADMIN_PASSWORD > /$vol_name/oracle/pwd.txt
#
# Creating schemas needed for sample domain ####
#===============================================
#
/$vol_name/oracle/oracle_common/bin/rcu -silent -createRepository -databaseType ORACLE -connectString $CONNECTION_STRING -dbUser sys -dbRole sysdba -useSamePasswordForAllSchemaUsers true -selectDependentsForComponents true -variables SOA_PROFILE_TYPE=SMALL,HEALTHCARE_INTEGRATION=NO -schemaPrefix $RCUPREFIX -component OPSS -component STB -component SOAINFRA -f < /$vol_name/oracle/pwd.txt
#
# Configuration of SOA domain
#=============================
/$vol_name/oracle/oracle_common/common/bin/wlst.sh -skipWLSModuleScanning /$vol_name/oracle/container-scripts/create_domain.py $jdbc_url $RCUPREFIX $ADMIN_PASSWORD $vol_name $admin_host $soa_host
#
# Creating domain env file
#=========================
mkdir -p /$vol_name/oracle/user_projects/domains/base_domain/servers/AdminServer/security
mkdir -p /$vol_name/oracle/user_projects/domains/base_domain/servers/soa_server1/security
mv /$vol_name/oracle/container-scripts/commEnv.sh /$vol_name/oracle/wlserver/common/bin/commEnv.sh
#
# Password less Adminserver starting
#===================================
echo "username=weblogic" > /$vol_name/oracle/user_projects/domains/base_domain/servers/AdminServer/security/boot.properties
echo "password="$ADMIN_PASSWORD >> /$vol_name/oracle/user_projects/domains/base_domain/servers/AdminServer/security/boot.properties
#
# Password less soaserver starting
#=================================
echo "username=weblogic" > /$vol_name/oracle/user_projects/domains/base_domain/servers/soa_server1/security/boot.properties
echo "password="$ADMIN_PASSWORD >> /$vol_name/oracle/user_projects/domains/base_domain/servers/soa_server1/security/boot.properties
#
# Setting env variables
#=======================
echo ". /$vol_name/oracle/user_projects/domains/base_domain/bin/setDomainEnv.sh" >> /$vol_name/oracle/.bashrc
echo "export PATH=$PATH:/$vol_name/oracle/common/bin:/$vol_name/oracle/user_projects/domains/base_domain/bin" >> /$vol_name/oracle/.bashrc
#
# Starting WebLogic Server
#=========================
/$vol_name/oracle/container-scripts/startAdmin.sh $vol_name