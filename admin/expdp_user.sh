#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <tns> <username>"
  echo
  echo "   Example: $0 ORCL TAG"
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
username=$2

log_date=`date +%m%d.%H%M%S`
dmp_file=expdp_${tns}_${username}.dmp.$log_date
log_file=expdp_${tns}_${username}.log.$log_date

expdp system/admin123@$tns schemas=$username dumpfile=${dmp_file} logfile=${log_file}

gzip -1 /mnt/dbbackup/$tns/*.dmp*

find /mnt/dbbackup/$tns -type f -mtime +1 -delete
