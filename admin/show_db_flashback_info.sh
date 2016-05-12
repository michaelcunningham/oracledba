#!/bin/sh

. /mnt/dba/admin/dba.lib

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_show_flashback_info_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_show_flashback_info_${log_date}.email

# Check to see if flashback is enabled.
flashback_on=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select flashback_on from v\\$database;
exit;
EOF`

flashback_on=`echo $flashback_on`

if [ "$flashback_on" = "NO" ]
then
  # If flashback of off print a message and exit
  echo
  echo
  echo "	############################################################"
  echo
  echo "	Flashback is not enabled for the $ORACLE_SID database."
  echo
  echo "	############################################################"
  echo
  echo
  exit
fi
echo
echo
echo
echo "*************************** Flashback Hidden Parameters **************************************"
echo 
sqlplus -s "/ as sysdba" <<EOF
SET LINESIZE 2000
--set pagesize 100
--SET TRIM ON TRIMSPOOL ON
SET HEADING ON
column parameter  format A40
column description format A70
column session_value format A30
column instance_value format A30
SELECT a.ksppinm as parameter, 
       a.ksppdesc as description, 
       b.ksppstvl as session_value, 
       c.ksppstvl as instance_value 
FROM x\$ksppi a, x\$ksppcv b, x\$ksppsv c 
WHERE a.indx = b.indx AND a.indx = c.indx AND a.ksppinm LIKE '/_flashback%' escape '/' ORDER BY 1;
exit;
EOF

echo
echo
echo "****************************** FLASHBACK LOG FILE INFO **********************************"
echo
sqlplus -s "/ as sysdba" << EOF
set serveroutput on
set linesize 200
set feedback off
set serveroutput on
set linesize 200
set feedback off

column name  format A50
column bytes format A16
column first_time format A30

select
        name,
        to_char( bytes, '999,999,999,999' ) as bytes,
        to_char(first_time,'MM/DD/YYYY HH24:MI:SS') as first_time
from V\$FLASHBACK_DATABASE_LOGFILE
/
exit;
EOF

echo
echo
echo "****************************** Redo log files size ***************************************"
echo
echo

sqlplus -s "/ as sysdba" << EOF
column name  format A50
column bytes format A16
column first_time format A30
set serveroutput on
set linesize 200
set feedback off


select lf.member as name, 
       to_char(l.bytes, '999,999,999,999' ) as bytes,
       to_char(l.first_time,'MM/DD/YYYY HH24:MI:SS') as first_time
from v\$logfile lf, v\$log l where l.group# = lf.group#
/
exit;
EOF
echo
echo

sqlplus -s "/ as sysdba" << EOF
set serveroutput on
set linesize 200
set feedback off

declare
	n_bytes				number;
	n_retention_target		integer;
	dt_oldest_flashback_time	date;
	n_oldest_flashback_time_min	number(9,2);
	n_flashback_size		integer;
	n_estimated_flashback_size	integer;
begin
	dbms_output.put_line( '	' );
	dbms_output.put_line( '****************************************************************************************************' );
	dbms_output.put_line( '	' );

	for r in(
		select	name, display_value
		from	v\$parameter
		where	name in( 'db_recovery_file_dest', 'db_recovery_file_dest_size' )
		order by name )
	loop
		dbms_output.put_line( rpad( r.name, 38 ) || lpad( r.display_value, 25 ) );
	end loop;

	dbms_output.put_line( '	' );

	select sum( bytes ) into n_bytes from v\$flashback_database_logfile;

	select	retention_target, oldest_flashback_time, ( sysdate - oldest_flashback_time ) * 1440 oldest_flashback_time_minutes,
		flashback_size, estimated_flashback_size
	into	n_retention_target, dt_oldest_flashback_time, n_oldest_flashback_time_min,
		n_flashback_size, n_estimated_flashback_size
	from	v\$flashback_database_log;

	dbms_output.put_line( 'Total bytes in flashback logfiles     ' || lpad( to_char( n_bytes, '999,999,999,999' ), 25 ) || '    (v\$flashback_database_logfile)' );
	dbms_output.put_line( 'Current Flashback Size                ' || lpad( to_char( n_flashback_size, '999,999,999,999' ), 25 ) || '    (v\$flashback_database_log)' );
	dbms_output.put_line( 'Estimated Flashback Size              ' || lpad( to_char( n_estimated_flashback_size, '999,999,999,999' ), 25 ) );
	dbms_output.put_line( 'Retention target                      ' || lpad( to_char( n_retention_target, '999999' ), 25 ) );
	dbms_output.put_line( 'Oldest Flashback Time Minutes         ' || lpad( to_char( n_oldest_flashback_time_min, '999999.00' ), 25 ) );
	dbms_output.put_line( 'Oldest Flashback Time                 ' || lpad( to_char( dt_oldest_flashback_time, 'mm/dd/yyyy hh:mi:ss AM' ), 25 ) );

	dbms_output.put_line( '	' );
	dbms_output.put_line( '****************************************************************************************************' );
	dbms_output.put_line( '	' );

end;
/

exit;
EOF
