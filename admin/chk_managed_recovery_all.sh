#!/bin/sh

####################################################################################################
#
# This script will loop thru all running instances on a server and execute the script
# chk_managed_recovery.sh
#
# There is no need to worry about databases that are not currently running because
# another script is used for that purpose.
# 
####################################################################################################

unset SQLPATH
export PATH=/usr/local/bin:$PATH
HOST=`hostname -s`

sid_list=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB" | sort`

for this_sid in $sid_list
do
  export ORACLE_SID=$this_sid
  /mnt/dba/admin/chk_managed_recovery.sh $ORACLE_SID
done
