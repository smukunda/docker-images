SOA on Docker
=============
Sample Docker configurations to facilitate installation, configuration, and environment setup for DevOps users. This project includes quick start [dockerfiles](dockerfiles/) and [samples](samples/) for SOA 12.2.1 based on Oracle Linux, Oracle JDK 8 (Server) and Oracle WebLogic Infrastructure.

The certification of SOA on Docker does not require the use of any file presented in this repository. Customers and users are welcome to use them as starters, and customize/tweak, or create from scratch new scripts and Dockerfiles.

## How to build and run
This project offers sample Dockerfiles for SOA 12cR2 (12.2.1). To assist in building the images, you can use the [buildDockerImage.sh](dockerfiles/buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that performs MD5 checks and is an easy way for beginners to get started. Expert users are welcome to directly call `docker build` with their preferred set of parameters.

### Building Oracle JDK (Server JRE) base image
Before you can build SOA image, you must download the Oracle Server JRE binary and drop in folder `OracleJDK/java-8` and build that image.

        $ cd OracleJDK/java-8
        $ sh build.sh

### Building WebLogic Infrastructure Docker Install Image
Before you can build SOA image, you must build WebLogic Infrastructure image as well.
 
Download the binary of WebLogic infrastructure and build the image using "buildDockerImage.sh" script for WebLogic.You need to choose the version as "12.2.1" and distribution as "infrastructure".

        $ sh buildDockerImage.sh -v 12.2.1 -i

Please refer README.md under [docker/OracleWebLogic](https://github.com/oracle/docker-images/tree/master/OracleWebLogic) for details on how to build WebLogic Infrastructure image.

### Building SOA Docker Install Image

**IMPORTANT:** you have to download the binary of SOA and put it in place (see `.download` files inside dockerfiles/<version>).

Before you build, choose the version as 12.2.1 and , then download the required packages (see .download files) and drop them in the folder of your distribution version 12.2.1. Then go into the **dockerfiles** folder and run the **buildDockerImage.sh** script as root.

        $ sh buildDockerImage.sh -h
        Usage: buildDockerImage.sh -v [version] [-s]
        Builds a Docker Image for Oracle SOA Suite .
        
        Parameters:
           -v: Release version to build. Required. E.g 12.2.1
           -s: skips the MD5 check of packages
        
        LICENSE CDDL 1.0 + GPL 2.0
        
        Copyright (c) 2016-2017: Oracle and/or its affiliates. All rights reserved.

## Sample command for building SOA Install Image

        $ sh buildDockerImage.sh -v 12.2.1

**IMPORTANT:** the resulting images will NOT have a domain pre-configured. You must extend the image with your own Dockerfile, and create your domain using WLST. You might take a look at the use case samples as well below.

## Samples for SOA Domain Creation
To give users an idea on how to create a domain from a custom Dockerfile to extend the SOA image, we provide a sample for 12c version. For an example on **12.2.1**, you can use the sample inside [samples/1221-domain](samples/1221-domain) folder.

### Sample Domain for SOA 12.2.1
This [Dockerfile](samples/1221-domain/Dockerfile) will create an image by extending **oracle/soa:12.2.1**. It will configure a **base_domain** with the following settings:

 * Admin Username: `weblogic`
 * Admin Password: provided by `ADMIN_PASSWORD` 
 * Oracle Linux Username: `oracle`
 * Oracle Linux Password: `welcome1`
 * WebLogic Domain Name: `base_domain`
 * Admin Server on port: `7001`
 * SOA server on port: `8001`
 * SOA SSL on port: `8002`

Make sure you first build the SOA 12.2.1 Image to get the install Image.

### Write your own SOA domain with WLST
The best way to create your own, or extend domains is by using [WebLogic Scripting Tool](https://docs.oracle.com/middleware/1221/cross/wlsttasks.htm). You can find an example of a WLST script to create domains at [create_domain.py](samples/1221-domain/container-scripts/create_domain.py). You may want to tune this script with your own setup to create DataSources and Connection pools, Security Realms, deploy artifacts, and so on. You can also extend images and override an existing domain, or create a new one with WLST.

## Building a sample Docker Image of a SOA Domain
To try a sample of a SOA image with a domain configured, follow the steps below:

  1. Make sure you have **oracle/soa:12.2.1** image built. If not go into **dockerfiles** and call 

        $ sh buildDockerImage.sh -v 12.2.1

  2. Go to folder **samples/1221-domain**
  3. Run the following command: 

        $ sh build.sh

  4. Verify you now have the image **oracle/soa-domain:12.2.1** in place with 

        $ docker images

**IMPORTANT:** the resulting images will NOT have a domain pre-configured. But, it has the scripts to create and configure a soa domain while creating a container out of the image.

### Create a docker volume

Run the below command to create a docker volume

       $ docker volume create --name <volumename>
       Eg: $ docker volume create --name soavolume
       
This volume will be created in "/var/lib/docker" directory or the location where "/var/lib/docker" points to.

Since the volume is created as "root" user, provide read/write/execute permissions to "oracle" user (by providing permissions to "others"), as all operations inside the container happens with "oracle" user login.

       $ chmod -R 777 /scratch/docker-env/docker/volumes/


### Create a volume container

Create a container to mount the above volume. In the same container execute scripts to copy all binaries from /u01 to volume mount point. Provide the volume name as an argument to the script. 

These are achieved by executing the below docker run

       $ docker run -it -v <volumename>:/<mount point name> --name <containername> oracle/soa-domain:12.2.1 volumeScripts.sh <volumename> 
       Eg: $ docker run -it -v soavolume:/soavolume --name volcontainer oracle/soa-domain:12.2.1 volumeScripts.sh soavolume

### Running a container with AdminServer

Create an environment file **wlsenv.list** under the folder **samples/1221-domain** with the below details:

        CONNECTION_STRING=<database_host_name>:port#:SID
        RCUPREFIX=<RCU_Prefix>
        DB_PASSWORD=<database_password>
        ADMIN_PASSWORD=<admin_password>
        hostname=<hostname>
        vol_name=<volumename>

To start a docker container with a SOA domain and the WebLogic AdminServer you can simply call **docker run -d oracle/soa-domain:12.2.1** command along with a call to the script to create and configure SOA domain.

While calling **docker run** command you need to pass the above **wlsenv.list** file as **--env-file**. Also mention the docker volume to be used. 

A sample docker run command is given below:

         $ docker run -i -t  -p 7001:7001 -v soavolume:/soavolume --name wlscontainer --env-file ./wlsenv.list oracle/soa-domain:12.2.1 configureSOAdomain.sh
         
The options "-i -t" in the above command runs the container in interactive mode and you will be able to see the commands running in the container. This includes the command for RCU creation, domain creation and configuration followed by starting the Admin Server.

**IMPORTANT:** You need to wait till all the above commands are run before you can access the AdminServer Web Console.

"volcontainer" is the docker volume that the container uses.

"wlscontainer" is the name of the container that is created as a result of the above docker run command.

"oracle/soa-domain:12.2.1" is the domain image which has the scripts to create and configure SOA domain

"configureSOAdomain.sh" is the script which is part of the domain image. Calling the script as part of the docker run command will replace the default action mentioned in the docker file with a call to this script.

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

To start a docker container with a SOA server you can simply call **docker run -d oracle/soa-domain:12.2.1** command along with a call to the script to start SOA Server.

While calling **docker run** command you need to pass the above **soaenv.list** file as **--env-file**. Also mention the docker volume to be used. 

A sample docker run command is given below:

         $  docker run -i -t  -p 8001:8001 -v soavolume:/soavolume --name soacontainer  --env-file ./soaenv.list oracle/soa-domain:12.2.1 startSOAServer.sh

The options "-i -t" in the above command runs the container in interactive mode and you will be able to see the commands running in the container. This includes the command to start the SOA Server followed by tailing of logs to keep the container up and running.

**IMPORTANT:** You need to wait till all the above commands are run before you can access the SOA-Infra URL.

"volcontainer" is the docker volume that the container uses.

"soacontainer" is the name of the container that is created as a result of the above docker run command.

"oracle/soa-domain:12.2.1" is the domain image which has the scripts to start SOA Server.

"startSOAServer.sh" is the script which is part of the domain image. Calling the script as part of the docker run command will replace the default action mentioned in the docker file with a call to this script.

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