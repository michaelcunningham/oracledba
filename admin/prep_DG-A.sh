#!/bin/bash

# This script will turn on archivelog mode and DG config for a database"

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

alter system set db_unique_name='${ORACLE_SID}A' scope=spfile;
alter system set db_file_name_convert='/u02/oradata/${ORACLE_SID}/data/' , '+DATA/${ORACLE_SID}/datafile' scope=spfile;
alter system set log_file_name_convert='/u02/oradata/${ORACLE_SID}/redo/' , '+DATA/${ORACLE_SID}/' scope=spfile;
alter system set standby_file_management=auto scope=spfile;
alter system set dg_broker_start=true scope=spfile;
alter system set fal_client='${ORACLE_SID}A' scope=spfile;
alter system set fal_server='${ORACLE_SID}B' scope=spfile;
alter system set service_names='${ORACLE_SID}, ${ORACLE_SID}A' scope=spfile;
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

##/mnt/dba/admin/archivelog_mode_on.sh $ORACLE_SID
