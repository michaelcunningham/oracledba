#!/bin/bash

# This script will turn on DG config for a database"

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus -s / as sysdba << EOF

ystem system db_unique_name='${ORACLE_SID}B' scope=spfile;
alter system set db_file_name_convert='+DATA/${ORACLE_SID}/datafile/', '/u02/oradata/${ORACLE_SID}/data/' scope=spfile;
alter system set log_file_name_convert='+DATA/${ORACLE_SID}/', '/u02/oradata/${ORACLE_SID}/redo/' scope=spfile;
alter system set standby_file_management=auto scope=spfile;
alter system set dg_broker_start=true scope=spfile;
alter system set fal_client='${ORACLE_SID}B' scope=spfile;
alter system set fal_server='${ORACLE_SID}A' scope=spfile;
alter system set service_names='STGPRT01, STGPRT01B';
create pfile from spfile;

show parameter db_unique_name
show parameter db_file_name_convert
show parameter log_file_name_convert
show parameter standby_file_management
show parameter dg_broker_start
show parameter fal_client
show parameter fal_server
show parameter service_names

exit;
EOF


