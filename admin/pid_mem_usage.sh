#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

. /dba/admin/dba.lib

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
pid_list_file=${adhoc_dir}/log/${ORACLE_SID}_pid_list.txt

sqlplus -s "/ as sysdba" << EOF > $pid_list_file
set pagesize 0
set feedback off
set term off

select	spid
from	v\$process
where	spid is not null
and	addr not in (
		select paddr from v\$session where sid = sys_context( 'USERENV', 'SID' ) );

exit;
EOF

printf "PID       SIZE(kB)   RSS(kB)  SHCln(kB)  ShDirt(kB)  PvCln(kB)  PvDirt(kB)  Swap(kB)   Pss(kB)\n"

#for PID in `cat $pid_list_file | head -3`
for PID in `cat $pid_list_file`
do
	VMSIZE=`cat /proc/$PID/smaps | grep ^60000000 -A1 | tail -1 | awk '{print $2}'`
	RSS=`cat /proc/$PID/smaps | grep ^60000000 -A2 | tail -1 | awk '{print $2}'`
	SHCLEAN=`cat /proc/$PID/smaps | grep ^60000000 -A3 | tail -1 | awk '{print $2}'`
	SHDIRTY=`cat /proc/$PID/smaps | grep ^60000000 -A4 | tail -1 | awk '{print $2}'`
	PVCLEAN=`cat /proc/$PID/smaps | grep ^60000000 -A5 | tail -1 | awk '{print $2}'`
	PVDIRTY=`cat /proc/$PID/smaps | grep ^60000000 -A6 | tail -1 | awk '{print $2}'`
	SWAP=`cat /proc/$PID/smaps | grep ^60000000 -A7 | tail -1 | awk '{print $2}'`
	PSS=`cat /proc/$PID/smaps | grep ^60000000 -A8 | tail -1 | awk '{print $2}'`
#	echo $PID" "$SMAP
#	printf "PID       SIZE(kB)   RSS(kB)  SHCln(kB)  ShDirt(kB)  PvCln(kB)  PvDirt(kB)  Swap(kB) \n"
	printf "%-6s" "$PID"
	printf "%12s" $VMSIZE
	printf "%10s" $RSS
	printf "%11s" $SHCLEAN
	printf "%12s" $SHDIRTY
	printf "%11s" $PVCLEAN
	printf "%12s" $PVDIRTY
	printf "%10s" $SWAP
	printf "%10s \n" $PSS
done
