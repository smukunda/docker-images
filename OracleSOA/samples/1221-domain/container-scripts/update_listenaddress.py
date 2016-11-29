#!/usr/bin/python
#
# Author:swati.mukundan@oracle.com
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
# SOA on Docker Default Domain
#
# Updates the listen address for managed server with the IP address of the host.
#
# Since : April, 2016
# Author: swati.mukundan@oracle.com
# ==============================================
import sys
#
# Assigning values to variables
# ==================================
domain_name  = os.environ.get("DOMAIN_NAME", "base_domain")
admin_port   = int(os.environ.get("ADMIN_PORT", "7001"))
admin_pass   = os.environ.get("ADMIN_PASSWORD", "welcome1")
soa_port = int(os.environ.get("SOA_PORT", "8001"))
soa_pass = os.environ.get("ADMIN_PASSWORD", "welcome1")
soassl_port = int(os.environ.get("SOA_SSL_PORT", "8002"))
cluster_name  = os.environ.get("CLUSTER_NAME", "docker_cluster")
#
# Reading db details and schema prefix passed from parent script
# ==============================================================
vol_name=sys.argv[1]
soa_host=sys.argv[2]
server=sys.argv[3]
#
# Setting domain path
# ===================
domain_path  = '/' + vol_name + '/oracle/user_projects/domains/' + domain_name
#
#
#
# Read domain for updates
# =======================
readDomain(domain_path)
#
#
# Set listen address
# ==================
cd('/')
cd('/Server/'+server)
cmo.setListenAddress(soa_host)

# Creating domain
# ==============================
updateDomain()
closeDomain()
exit()
