#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_dg_verify_configuration_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_dg_verify_configuration_${log_date}.email

ORACLE_SID_lower=`echo $ORACLE_SID | tr '[:upper:]' '[:lower:]'`
EMAILDBA=dba@tagged.com

# select value from v$parameter where name = 'db_file_name_convert';
# select value from v$parameter where name = 'db_unique_name';
# select value from v$parameter where name = 'dg_broker_start';
# select value from v$parameter where name = 'fal_server';
# select value from v$parameter where name = 'log_archive_dest_1';
# select value from v$parameter where name = 'log_file_name_convert';
# select value from v$parameter where name = 'service_names';

database_role=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select database_role from v\\$database;
exit;
EOF`

database_role=`echo $database_role`

if [ "$database_role" != "PRIMARY" ]
then
  exit
fi

db_file_name_convert=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'db_file_name_convert';
exit;
EOF`

db_file_name_convert=`echo $db_file_name_convert`
 
db_unique_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'db_unique_name';
exit;
EOF`

db_unique_name=`echo $db_unique_name`
db_unique_name_lower=`echo $db_unique_name | tr '[:upper:]' '[:lower:]'`
 
dg_broker_start=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'dg_broker_start';
exit;
EOF`

dg_broker_start=`echo $dg_broker_start`
 
fal_server=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'fal_server';
exit;
EOF`

fal_server=`echo $fal_server`
 
log_archive_dest_1=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'log_archive_dest_1';
exit;
EOF`

log_archive_dest_1=`echo $log_archive_dest_1`
 
log_file_name_convert=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'log_file_name_convert';
exit;
EOF`

log_file_name_convert=`echo $log_file_name_convert`
 
service_names=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'service_names';
exit;
EOF`

service_names=`echo $service_names`
 

echo
echo "	Current settings"
echo "	---------------------------------------------------------"
echo "	ORACLE_SID_lower       = "$ORACLE_SID_lower
echo "	db_file_name_convert   = "$db_file_name_convert
echo "	db_unique_name         = "$db_unique_name
echo "	dg_broker_start        = "$dg_broker_start
echo "	fal_server             = "$fal_server
echo "	log_archive_dest_1     = "$log_archive_dest_1
echo "	log_file_name_convert  = "$log_file_name_convert
echo "	service_names          = "$service_names
echo


echo
echo "	Changes to be made"
echo "	---------------------------------------------------------"
if [ "$db_file_name_convert" != "/noop/, /noop/" ]
then
  echo "	db_file_name_convert ....."
  echo "		dgmgrl"
  echo "		edit database $db_unique_name_lower set property DbFileNameConvert = '/noop/, /noop/';"
  echo
fi

if [ "$log_file_name_convert" != "/noop/, /noop/" ]
then
  echo "	log_file_name_convert ....."
  echo "		dgmgrl"
  echo "		edit database $db_unique_name_lower set property LogFileNameConvert = '/noop/, /noop/';"
  echo
fi

echo
/mnt/dba/admin/configure_has.sh $ORACLE_SID > $log_file
tail -1 $log_file
