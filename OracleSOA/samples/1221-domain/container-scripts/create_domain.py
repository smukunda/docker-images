#!/usr/bin/python
#
# Author:swati.mukundan@oracle.com
#
# Copyright (c) 2016-2017 Oracle and/or its affiliates. All rights reserved.
#
# SOA on Docker Default Domain
#
# Domain, as defined in DOMAIN_NAME, will be created in this script. Name defaults to 'base_domain'.
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
jdbc_url = sys.argv[1]
prefix = sys.argv[2]
admin_pass=sys.argv[3]
soa_pass=sys.argv[3]
vol_name=sys.argv[4]
admin_host=sys.argv[5]
#
# Setting domain path
# ===================
domain_path  = '/' + vol_name + '/oracle/user_projects/domains/' + domain_name
#
#
# Setting RCU schema names with prefixes
# ======================================
schema_OPSS = prefix+'_OPSS'
schema_STB = prefix+'_STB'
schema_MDS = prefix+'_MDS'
schema_UMS = prefix+'_UMS'
schema_SOAINFRA = prefix+'_SOAINFRA'
#
#
# Open default domain template
# ============================
template='/' + vol_name + '/oracle/wlserver/common/templates/wls/wls.jar'
readTemplate(template)
#
# Configure the Administration Server and SSL port.
# =========================================================
cd('Servers/AdminServer')
set('ListenAddress', admin_host)
set('ListenPort', admin_port)
#
# Define the user password for weblogic
# =====================================
cd('/')
cd('Security/base_domain/User/weblogic')
cmo.setPassword(admin_pass)
#
# Write the domain and close the domain template
# ==============================================
setOption('OverwriteDomain', 'true')
setOption('ServerStartMode','prod')
#
# Setting node manager property values
# =====================================
cd('/')
cd('NMProperties')
set('ListenAddress','')
set('ListenPort',5556)
set('NativeVersionEnabled', 'false')
set('StartScriptEnabled', 'false')
set('SecureListener', 'false')
#
# Define a WebLogic Cluster
# =========================
cd('/')
create(cluster_name, 'Cluster')
cd('/Clusters/%s' % cluster_name)
cmo.setClusterMessagingMode('unicast')
#
writeDomain(domain_path)
closeTemplate()
readDomain(domain_path)
#
# Configuring domain with Oracle SOA Suite template
# =================================================
selectTemplate('Oracle SOA Suite')
loadTemplates()
showTemplates()
#
#
# Setting OPSS schema properties
# ==============================
cd('/JdbcSystemResource/opss-data-source/JdbcResource/opss-data-source/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.OracleDriver')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_OPSS)
cd('/JdbcSystemResource/opss-audit-DBDS/JdbcResource/opss-audit-DBDS/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.OracleDriver')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_OPSS)
cd('/JdbcSystemResource/opss-audit-viewDS/JdbcResource/opss-audit-viewDS/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.OracleDriver')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_OPSS)
#
#
# Setting STB schema properties
# ==============================
cd('/JdbcSystemResource/LocalSvcTblDataSource/JdbcResource/LocalSvcTblDataSource/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.OracleDriver')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_STB)
#
# Setting MDS schema properties
# ==============================
cd('/Server/soa_server1')
cmo.setListenPort(soa_port)
set('ListenAddress','')
create('soa_server1','SSL')
cd('SSL/soa_server1')
cmo.setEnabled(true)
cmo.setListenPort(soassl_port)
cd('/JdbcSystemResource/mds-owsm/JdbcResource/mds-owsm/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.OracleDriver')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_MDS)
cd('/JdbcSystemResource/mds-soa/JdbcResource/mds-soa/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.OracleDriver')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_MDS)
#
# Setting UMS schema properties
# ==============================
cd('/JdbcSystemResource/OraSDPMDataSource/JdbcResource/OraSDPMDataSource/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_UMS)
#
# Setting SOA-INFRA schema properties
# ==============================
cd('/JdbcSystemResource/EDNDataSource/JdbcResource/EDNDataSource/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.xa.client.OracleXADataSource')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_SOAINFRA)
cd('/JdbcSystemResource/EDNLocalTxDataSource/JdbcResource/EDNLocalTxDataSource/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.OracleDriver')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_SOAINFRA)
cd('/JdbcSystemResource/SOADataSource/JdbcResource/SOADataSource/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.xa.client.OracleXADataSource')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_SOAINFRA)
cd('/JdbcSystemResource/SOALocalTxDataSource/JdbcResource/SOALocalTxDataSource/JdbcDriverParams/NO_NAME')
cmo.setUrl(jdbc_url)
cmo.setDriverName('oracle.jdbc.OracleDriver')
set('PasswordEncrypted', admin_pass)
cd('Properties/NO_NAME/Property/user')
cmo.setValue(schema_SOAINFRA)
#
# Adding SOA Server to cluster
# ============================
cd('/')
assign("Server", "soa_server1", "Cluster", "docker_cluster")
#
# Creating domain
# ==============================
updateDomain()
closeDomain()
exit()