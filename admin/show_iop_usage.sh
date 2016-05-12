#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

# echo $this_asm
unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect / as sysdba

set verify off
set pagesize 100
set feedback off
set serveroutput on

define inst_no=1
define slotsize=900
--define slotsize=3600
define rangesize=100

column iop_range format a20
column slots format 999,999,999

break on report
compute sum of slots on report

begin
	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '########################################' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Slot size = ' || &slotsize );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '########################################' );
end;
/

select	lpad( trunc( vpersec/&rangesize ) * &rangesize, 6 ) ||' - '|| lpad( ( ( trunc( vpersec/&rangesize ) + 1 ) * &rangesize ) - 1, 6 ) iop_range,
	sum( slots ) slots
from	(
	select	snap_delta/( extract( day from ( begin_snap_time - end_snap_time ) ) * 86400 + extract( hour from ( begin_snap_time - end_snap_time ) ) * 3600
			+ extract( minute from ( begin_snap_time - end_snap_time ) ) * 60+ extract( second from ( begin_snap_time - end_snap_time ) ) ) vpersec,
		round( ( extract(day from ( begin_snap_time - end_snap_time ) ) * 86400 + extract( hour from ( begin_snap_time - end_snap_time ) ) * 3600
			+ extract(minute from ( begin_snap_time - end_snap_time ) ) * 60 + extract( second from ( begin_snap_time - end_snap_time ) ) )/&slotsize ) slots
	from	(
		select	ss.begin_interval_time begin_snap_time,
			lag( ss.begin_interval_time ) over( order by ss.snap_id ) end_snap_time,
			st.value - lag( st.value, 1, 0 ) over( order by ss.snap_id ) snap_delta
		from	sys.wrh\$_sysstat st, sys.wrm\$_snapshot ss, v\$statname sn
		where	st.snap_id=ss.snap_id
		and	ss.instance_number = 1
		and	st.instance_number = 1
		and	ss.dbid=st.dbid
		and	st.stat_id = sn.stat_id
		and	sn.name = 'physical read total IO requests'
		)
	where	end_snap_time is not null
	and	snap_delta > 0
	and	trunc( end_snap_time ) = trunc( begin_snap_time )
	)
group by lpad( trunc( vpersec/&rangesize ) * &rangesize, 6 ) ||' - '|| lpad( ( ( trunc( vpersec/&rangesize ) + 1 ) * &rangesize ) - 1, 6 )
order by lpad( trunc( vpersec/&rangesize ) * &rangesize, 6 ) ||' - '|| lpad( ( ( trunc( vpersec/&rangesize ) + 1 ) * &rangesize ) - 1, 6 );

exit;
EOF
