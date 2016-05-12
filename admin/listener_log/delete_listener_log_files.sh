#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <ORACLE_SID>"
  echo
  echo "	Example: $0 novadev"
  echo
  exit 2
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/admin/listener_log/log/${ORACLE_SID}_listener_log.log

netlog_dir=/dba/admin/listener_log/log_files

#
# What is the name of the listener log file for this database.
#
host=`hostname | cut -d. -f1`
listener_cmd=`ps -eo "%a" | grep "l_${ORACLE_SID} " | grep tnslsnr | awk '{print $1}'`
listener_cmd=`echo $listener_cmd | sed s/tnslsnr/lsnrctl/g`
listener_log_file=`${listener_cmd} status l_${ORACLE_SID} | grep "Listener Log File" | awk '{print $4}'`
listener_log_dir=`dirname $listener_log_file`

echo ...................... cleaning up

rm $netlog_dir/${ORACLE_SID}_log.xml.5
rm $netlog_dir/${ORACLE_SID}_log.xml.4
rm $netlog_dir/${ORACLE_SID}_log.xml.3
rm $netlog_dir/${ORACLE_SID}_log.xml.2
rm $netlog_dir/${ORACLE_SID}_log.xml.1
rm $netlog_dir/${ORACLE_SID}_log.xml
