#!/bin/sh

# alter database clear logfile group 1;
# alter database drop logfile group 1;
# alter database add logfile group 1 ( '+DATAPDB04/PDB04/log01.ora' ) size 1g reuse;

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
# Find the name of the LOG* diskgroup
################################################################################
data_dg_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select name from v\\$asm_diskgroup where name like '%DATA%';
exit;
EOF`
data_dg_name=`echo $data_dg_name`

if [ "$data_dg_name" = "" ]
then
  echo
  echo "The LOG diskgroup name could not be found."
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
  echo "The DB_UNIQUE_NAME could not be found."
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

echo 'data_dg_name      = '$data_dg_name
echo 'db_name           = '$db_name
echo 'redolog_size      = '$redolog_size

sqlplus /nolog << EOF
connect -s / as sysdba
set feedback off
set termout off
set serveroutput on
set linesize 250

--alter system checkpoint;

declare
	s_sql varchar2(1000);
begin
	dbms_output.put_line( 'Starting move of standby redolog files.' );

	if '$managed_recovery' = 'true' then
		s_sql := 'alter database recover managed standby database cancel';
		dbms_output.put_line( s_sql || ';' );
		--execute immediate s_sql;
	end if;

	for r in( select group# from v\$logfile where type = 'STANDBY' order by group# ) loop
		s_sql := 'alter database drop logfile group ' || r.group#;
		dbms_output.put_line( s_sql || ';' );
		begin
			--execute immediate s_sql;
			null;
		exception
			when others then null;
		end;
		s_sql := 'alter database add standby logfile thread 1 group ' || r.group#
			|| ' ( ''+$data_dg_name/$db_name/stby_log' || r.group# || '.ora'' ) size $redolog_size reuse';
		dbms_output.put_line( s_sql || ';' );
		begin
			--execute immediate s_sql;
			null;
		exception
			when others then null;
                end;

	end loop;

	if '$managed_recovery' = 'true' then
		s_sql := 'alter database recover managed standby database disconnect';
		dbms_output.put_line( s_sql || ';' );
		--execute immediate s_sql;
	end if;
end;
/

@/mnt/dba/scripts/redo.sql

exit;
EOF

