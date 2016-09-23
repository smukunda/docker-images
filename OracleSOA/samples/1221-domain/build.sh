#!/bin/bash
#
# Since: April, 2016
# Author: swati.mukundan@oracle.com
# Description: script to build a Docker image for SOA with scripts to create and configure SOA domain. The install mode is SOA Suite alone, BPM is not included
#
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
#
docker build --force-rm=true --no-cache=true -t oracle/soa-domain:12.2.1 -f Dockerfile .