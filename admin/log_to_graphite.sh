#!/bin/sh

if [ $# -lt 2 ]
then
   echo
   echo "	Usage: $0 <tree_node> <numeric_value> [time_value"
   echo
   echo "	$0 tagged.TDB.standby.\$ORACLE_SID 8"
   echo
   exit
fi

if [ "$3" = "" ]
then
  time_value=$(/bin/date +%s)
else
  time_value=$3
fi

# Update graphite for the DBA monitoring station.
graphite_ip=`/mnt/dba/admin/get_graphite_ip.sh`
# echo "$1 $2 "$(/bin/date +%s) | /usr/bin/nc -w 3 $graphite_ip 2003
echo "$1 $2 $time_value" | /usr/bin/nc -w 3 $graphite_ip 2003
