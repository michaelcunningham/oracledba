#!/bin/bash

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
export ORACLE_SID=$1
# export PATH=/usr/local/bin:$PATH
export PATH="/usr/local/bin:"`echo $PATH | sed "s/\/usr\/local\/bin://g"`
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

data_volume_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select	sum(bytes)
from	(
	select bytes/1024/1024 bytes from v\\$datafile
	union all
	select bytes/1024/1024 bytes from v\\$tempfile
	);
exit;
EOF`

data_volume_size=`echo $data_volume_size`
echo $data_volume_size
