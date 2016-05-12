#!/bin/sh

# alter database recover managed standby database cancel;
# alter database clear logfile group 21;
# alter database drop standby logfile group 21;
# alter database add standby logfile thread 1 group 21 ( '+DATAPDB04/PDB04/stby_log21.ora' ) size 1g reuse;
# alter database recover managed standby database disconnect;

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 orcl"
  echo
  exit
else
  export ORACLE_SID=$1
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

echo "Starting .............................. "$0
echo

################################################################################
# Find the location of the standby redo logs
################################################################################
srl_dir_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select	substr( lf.member, 1, instr( lf.member, '/', -1 ) - 1 ) as srl_dir_name
from	v\\$standby_log sl, v\\$logfile lf
where	sl.group# = lf.group#
and	rownum = 1;
exit;
EOF`
srl_dir_name=`echo $srl_dir_name`

if [ "$srl_dir_name" = "" ]
then
  echo
  echo "The LOG diskgroup or directory name could not be determined."
  echo "Exiting..."
  echo
fi

################################################################################
# Find the db_name
################################################################################
db_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'db_name';
exit;
EOF`
db_name=`echo $db_name`

if [ "$db_name" = "" ]
then
  echo
  echo "The DB_NAME could not be found."
  echo "Exiting..."
  echo
fi

################################################################################
# Find the size of the redolog files.
# Just use the CURRENT logfile
################################################################################
redolog_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select bytes from v\\$log where status = 'CURRENT';
exit;
EOF`
redolog_size=`echo $redolog_size`

if [ "$redolog_size" = "" ]
then
  echo
  echo "The redo logfile size could not be found."
  echo "Exiting..."
  echo
fi

################################################################################
# Is this database in managed recovery mode?
################################################################################
cnt=`$ORACLE_HOME/bin/sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select count(*) from v\\$managed_standby where process like 'MRP%';
exit;
EOF`

if [ $cnt -gt 0 ]
then
  # Database has a MRP (Managed Recovery Process) running.
  # We need to stop it prior to rebuilding standby redo logs.
  managed_recovery=true
fi

echo 'srl_dir_name      = '$srl_dir_name
echo 'db_name           = '$db_name
echo 'redolog_size      = '$redolog_size
echo 'managed_recovery  = '$managed_recovery

sqlplus /nolog << EOF
connect -s / as sysdba
set sqlprompt ''
set sqlnumber off
set feedback off
set termout off
set serveroutput on
set linesize 250

--alter system checkpoint;

declare
	s_sql varchar2(1000);
begin
	dbms_output.put_line( 'Starting rebuld of standby redolog files.' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );

	if '$managed_recovery' = 'true' then
		s_sql := 'alter database recover managed standby database cancel';
		dbms_output.put_line( s_sql || ';' );
		execute immediate s_sql;
	end if;

	for r in( select group# from v\$logfile where type = 'STANDBY' order by group# ) loop
		s_sql := 'alter database clear logfile group ' || r.group#;
		dbms_output.put_line( s_sql || ';' );
		s_sql := 'alter database drop standby logfile group ' || r.group#;
		dbms_output.put_line( s_sql || ';' );
		begin
			execute immediate s_sql;
			null;
		exception
			when others then null;
		end;
		s_sql := 'alter database add standby logfile thread 1 group ' || r.group#
			|| ' ( ''$srl_dir_name/stby_log' || r.group# || '.ora'' ) size $redolog_size reuse';
		dbms_output.put_line( s_sql || ';' );
		begin
			execute immediate s_sql;
			null;
		exception
			when others then null;
                end;

	end loop;

	if '$managed_recovery' = 'true' then
		s_sql := 'alter database recover managed standby database disconnect';
		dbms_output.put_line( s_sql || ';' );
		execute immediate s_sql;
	end if;

	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
end;
/

@/mnt/dba/scripts/redo.sql

exit;
EOF

