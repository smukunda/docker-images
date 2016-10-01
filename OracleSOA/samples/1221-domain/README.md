Example of Image with SOA Domain
================================
This Dockerfile extends the Oracle SOA 12.2.1 install image and creates a dummy SOA install image with scripts to create and configure SOA domain.

# How to build image and run container
First make sure you have built **oracle/soa:12.2.1** by running following command as root user

        $ docker images 
                                                     
Now to build this sample, run:

        $ docker build --force-rm=true --no-cache=true -t oracle/soa-domain:12.2.1 -f Dockerfile .
        
The above "docker build" command will create a dummy SOA install image from "oracle/soa:12.2.1" and will copy the [container-scripts](samples/1221-domain/container-scripts) into the image.

[container-scripts](samples/1221-domain/container-scripts) have scripts to create and configure a SOA domain with running Admin Server and SOA Server. The script will be called during "docker run". 

### Create a docker volume

Run the below command to create a docker volume

       $ docker volume create --name <volumename>
       Eg: $ docker volume create --name soavolume
       
This volume will be created in "/var/lib/docker" directory or the location where "/var/lib/docker" points to.

Since the volume is created as "root" user, provide read/write/execute permissions to "oracle" user (by providing permissions to "others"), as all operations inside the container happens with "oracle" user login.

       $ chmod -R 777 <path to docker volume>/volumes/


### Create a volume container

Create a container to mount the above volume. In the same container execute scripts to copy all binaries from /u01 to volume mount point. Provide the volume name as an argument to the script. 

These are achieved by executing the below docker run

       $ docker run -it -v <volumename>:/<mount point name> --name <containername> oracle/soa-domain:12.2.1 volumeScripts.sh <volumename> 
       Eg: $ docker run -it -v soavolume:/soavolume --name volcontainer oracle/soa-domain:12.2.1 volumeScripts.sh soavolume

Create an environment file **wlsenv.list** under the folder **samples/1221-domain** with the below details:

        CONNECTION_STRING=<database_host_name>:port#:SID
        RCUPREFIX=<RCU_Prefix>
        DB_PASSWORD=<database_password>
        ADMIN_PASSWORD=<admin_password>
        hostname=<hostname>
        vol_name=<volumename>

 - CONNECTION_STRING - Connection details to your database should be specified in wlsenv.list. For example, in case of Oracle DB, connection string will be of the format dbhost:dbport:dbsid. This db should be up and running.

 - RCUPREFIX - Schema prefix used to create necessary schemas should be specified in wlsenv.list

 - DB_PASSWORD - Password to connect to the db mentioned above.

 - ADMIN_PASSWORD - Password for the Admin Server and SOA Server.

 - hostname - Name of the host where all the docker activities are happening.

 - vol_name - Name of the volume that is created earlier.

To start a docker container with a SOA server you can simply call **docker run -d oracle/soa-domain:12.2.1** command along with a call to the script to start SOA Server. You will also need to pass **soaenv.list** file as **--env-file** and mention the **docker volume** to be used. 

A sample docker run command is given below:

         $ docker run -i -t  -p 7001:7001 -v soavolume:/soavolume --name wlscontainer --env-file ./wlsenv.list oracle/soa-domain:12.2.1 configureSOAdomain.sh

The options "-i -t" in the above command runs the container in interactive mode and you will be able to see the commands running in the container. This includes the command for RCU creation, domain creation and configuration followed by starting the Admin Server.

**IMPORTANT:** You need to wait till all the above commands are run before you can access the AdminServer Web Console.

 * "volcontainer" is the docker volume that the container uses.

 * "wlscontainer" is the name of the container that is created as a result of the above docker run command.

 * "oracle/soa-domain:12.2.1" is the domain image which has the scripts to create and configure SOA domain

 * "configureSOAdomain.sh" is the script which is part of the domain image. Calling the script as part of the docker run command will replace the default action mentioned in the docker file with a call to this script.

The script creates and configures a SOA domain with Admin Server and SOA Server.

Further, the script will start the Admin Server and waits until it is up and running. Once the Admin Server is in "RUNNING" status, the below message will be displayed:

         Admin server is running
         Admin server running, ready to start SOA server
        
Once the Admin Server is up logs will be tailed and displayed to keep the container running.

Now you can access the AdminServer Web Console at [http://localhost:7001/console](http://localhost:7001/console).

### Running a container with SOA Server

Create an environment file **soaenv.list** under the folder **samples/1221-domain** with the below details:

        vol_name=<volumename>
        hostname=<hostname>
        adminport=<port number where Admin Server is running>

 - vol_name - Name of the volume that is created earlier.
 
 - hostname - Name of the host where all the docker activities are happening.
  
 - adminport - Port number where admin server is running.

To start a docker container with a SOA domain and the WebLogic AdminServer you can simply call **docker run -d oracle/soa-domain:12.2.1** command along with a call to the script to create and configure SOA domain. You will also need need to pass the above **wlsenv.list** file as **--env-file** and **docker volume** to be used.

A sample docker run command is given below:

         $  docker run -i -t  -p 8001:8001 -v soavolume:/soavolume --name soacontainer  --env-file ./soaenv.list oracle/soa-domain:12.2.1 startSOAServer.sh

The options "-i -t" in the above command runs the container in interactive mode and you will be able to see the commands running in the container. This includes the command to start the SOA Server followed by tailing of logs to keep the container up and running.

**IMPORTANT:** You need to wait till all the above commands are run before you can access the SOA-Infra URL.

 * "volcontainer" is the docker volume that the container uses.

 * "soacontainer" is the name of the container that is created as a result of the above docker run command.

 * "oracle/soa-domain:12.2.1" is the domain image which has the scripts to start SOA Server.

 * "startSOAServer.sh" is the script which is part of the domain image. Calling the script as part of the docker run command will replace the default action mentioned in the docker file with a call to this script.

The script starts the SOA Server.

Once the SOA Server is in "RUNNING" status, the below message will be displayed:

         SOA server is running
         SOA server has been started
        
Once the SOA Server is up logs will be tailed and displayed to keep the container running.

Now you can access the SOA Web Console at [http://localhost:8001/soa-infra](http://localhost:8001/soa-infra).

## License

To download and run SOA 12c Distribution regardless of inside or outside a Docker container, and regardless of the distribution, you must download the binaries from Oracle website and accept the license indicated at that page.

To download and run Oracle JDK regardless of inside or outside a Docker container, you must download the binary from Oracle website and accept the license indicated at that pge.

All scripts and files hosted in this project and GitHub [docker/OracleSOA](./) repository required to build the Docker images are, unless otherwise noted, released under the Common Development and Distribution License (CDDL) 1.0 and GNU Public License 2.0 licenses.

## Copyright

Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.