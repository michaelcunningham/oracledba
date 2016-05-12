#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <tns> <table_name>"
  echo
  echo "   Example: $0 ORCL CUSTOMER"
  echo "   Example: $0 ORCL \"CUSTOMER,INVOICE,DEPOSITS\""
  echo
  exit
fi

unset SQLPATH
# Just pick the first ORACLE_SID we can find that is running.
export ORACLE_SID=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB" | sort | head -1`
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

tns=$1
username=TAG
userpwd=zx6j1bft
table_name=$2

log_date=`date +%m%d.%H%M%S`
dmp_file=${tns}_${username}_tables.dmp
log_file=${tns}_${username}_tables_expdp.log

job_name=EXP_${username}_TABLES

expdp $username/$userpwd@$tns directory=external_dir job_name=EXP_${username}_TABLES tables=$table_name dumpfile=${dmp_file} logfile=${log_file}
