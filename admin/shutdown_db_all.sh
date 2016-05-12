#!/bin/sh

####################################################################################################
# This script will start all databases on a server.
# It will do the following process
#	1) Read the list of databases from the /etc/oratab file
#	2) If database not running, call /mnt/dba/admin/startup_db.sh $ORACLE_SID
# 
####################################################################################################
unset SQLPATH
export PATH=/usr/local/bin:$PATH
HOST=`hostname -s`

sid_list=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB|\]" | sort`

for this_sid in $sid_list
do
  export ORACLE_SID=$this_sid

  echo
  echo "##################################################"
  echo "#"
  echo "#  Shutting down \"${ORACLE_SID}\" database."
  echo "#"
  echo "##################################################"
  echo

  ORAENV_ASK=NO . /usr/local/bin/oraenv -s
  nohup /mnt/dba/admin/shutdown_db.sh $ORACLE_SID > /mnt/dba/logs/$ORACLE_SID/shutdown_db.log 2>&1 &
done

result=`ps x | grep -v grep | grep shutdown_db`
if [ "$result" != "" ]
then
  echo
  echo "##################################################"
  echo "#"
  echo "#  Waiting for nohup processes to complete."
  echo "#"
  echo "##################################################"
  echo
  time wait
  echo
  echo "##################################################"
  echo "#"
  echo "#  All nohup processes have completed."
  echo "#"
  echo "##################################################"
  echo
fi
