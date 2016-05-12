#!/bin/ksh

#
# We need an ORACLE_SID to use so we can set the environment.  Let's find one.
# Since this script can be run from any Linux server we need to do this dynamically
# because we don't know which instance to use up front.
#
export ORACLE_SID=`ps -ef | grep ora_pmon | grep -v "grep ora_pmon"| awk '{print $8}' | awk -F_ '{print $3}' | head -1`
export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

REMOTE_SID=fdev

# Get the tns string
tns=`/dba/admin/get_tns_from_orasid.sh $REMOTE_SID`
retval=$?
if [ "$retval" != "0" ]
then
  echo "Could not find the tns string for "$REMOTE_SID
  exit $retval
fi

syspwd=`get_sys_pwd $tns`
retval=$?
if [ "$retval" != "0" ]
then
  echo "Could not find the sys password for "$REMOTE_SID
  exit $retval
fi

sqlplus -s sys/$syspwd@$tns as sysdba @/dba/admin/connect.sql
status=$?
if [ $status -ne 0 ]
then
  dp 5/DB FAULT - cannot connect to FDEV
  dp 2/DB FAULT - cannot connect to FDEV
  exit 2
else
  exit 0
fi
exit
