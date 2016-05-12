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

# For debugging
log_date=`date`
unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

tns_string=`tnsping $ORACLE_SID`
host_location=`echo $tns_string | awk '{print match($0, "HOST")}'`
host_part=`echo $tns_string | awk '{print substr($0,match($0,"HOST"),23)}'`
host_part=`echo $host_part | awk '{print substr($0,0,match($0,")")-1)}'`
vip=`echo $host_part | cut -d" " -f3`

#
# Now make sure the vip actually exists on this machine.
# We do this because if this is a standby machine we would still be able to
# find the vip with the method above, but it might not actually be
# on this machine.
#

result=`/sbin/ifconfig | grep "$vip"`
if [ -z "$result" ]
then
  # This means the vip is NOT on this machine
  unset vip
fi

# echo $tns_string
# echo $host_location
# echo $host_part
echo $vip
