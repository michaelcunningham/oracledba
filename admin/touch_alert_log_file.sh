#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 novadev"
  echo
  exit
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

alert_log_dir=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba

select value from v\\$parameter where name = 'background_dump_dest';

exit;
EOF`

alert_log_dir=`echo $alert_log_dir`
alert_log_file=$alert_log_dir/alert_$ORACLE_SID.log

echo 'alert_log_dir         : '$alert_log_dir
echo 'alert_log_file        : '$alert_log_file

rm ${alert_log_file}.1
mv $alert_log_file ${alert_log_file}.1
> $alert_log_file
