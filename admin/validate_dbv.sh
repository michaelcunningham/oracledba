#!/bin/sh
#set -x

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
log_file=${log_dir}/${ORACLE_SID}_template_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_template_${log_date}.email
mkdir -p $log_dir

EMAILDBA=dba@tagged.com

db_block_size=`sqlplus -L -s / as sysdba <<EOF
set heading off
set pages 0
set feedback off

SELECT  value FROM  v\\$parameter WHERE name = LOWER('DB_BLOCK_SIZE');
exit;
EOF`


db_files=`sqlplus -L -s / as sysdba <<EOF
set heading off
set feedback off
set pagesize 0

select name from v\\$datafile;
exit;
EOF
`
#db_files=`echo $db_files`


for i in `echo $db_files`
do
echo "dbv file='$i' blocksize=$db_block_size"
dbv file='$i' blocksize=$db_block_size
done


