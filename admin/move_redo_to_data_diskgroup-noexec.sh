#!/bin/sh

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

# We are going to override the redolog_size to 1G to make a standard
redolog_size=1g

if [ "$redolog_size" = "" ]
then
  echo
  echo "The redo logfile size could not be found."
  echo "Exiting..."
  echo
fi

################################################################################
# Find the current group # being used.
################################################################################
current_group=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select group# from v\\$log where status = 'CURRENT';
exit;
EOF`
current_group=`echo $current_group`
current_group_pad=`echo $current_group | awk '{printf "%02d\n", $0}'`

echo 'data_dg_name      = '$data_dg_name
echo 'db_name           = '$db_name
echo 'redolog_size      = '$redolog_size
echo 'current_group     = '$current_group
echo 'current_group_pad = '$current_group_pad

sqlplus /nolog << EOF
connect -s / as sysdba
set feedback off
set termout off
set serveroutput on
set linesize 150

--alter system checkpoint;

declare
	s_sql varchar2(1000);
begin
	dbms_output.put_line( 'Starting online redolog move.' );
	dbms_output.put_line( 'alter system checkpoint;' );
	for r in( select group# from v\$logfile where type = 'ONLINE' order by group# ) loop
		if r.group# <> $current_group then
			s_sql := 'alter database drop logfile group ' || r.group#;
			dbms_output.put_line( s_sql || ';' );
			--execute immediate s_sql;
			s_sql := 'alter database add logfile thread 1 group ' || r.group#
				|| ' ( ''+$data_dg_name/$db_name/log' || lpad( r.group#, 2, '0' ) || '.ora'' ) size $redolog_size reuse';
			dbms_output.put_line( s_sql || ';' );
			--execute immediate s_sql;
		end if;
	end loop;
end;
/

-- Switch redolog file.
--alter system archive log current;

-- Make sure all data is written to disk so the redolog file that was "current_group"
-- is no longer ACTIVE.
--alter system checkpoint;

-- Now, let's do the logfile that was CURRENT at the start of this process.
declare
	s_sql varchar2(1000);
begin
	dbms_output.put_line( 'Moving final online redolog move.' );
	dbms_output.put_line( 'alter system archive log current;' );
	dbms_output.put_line( 'alter system checkpoint;' );
	s_sql := 'alter database drop logfile group ' || $current_group;
	dbms_output.put_line( s_sql || ';' );
	--execute immediate s_sql;
	s_sql := 'alter database add logfile thread 1 group ' || $current_group
		|| ' ( ''+$data_dg_name/$db_name/log' || lpad( $current_group, 2, '0' ) || '.ora'' ) size $redolog_size reuse';
	dbms_output.put_line( s_sql || ';' );
	--execute immediate s_sql;
end;
/

@/mnt/dba/scripts/redo.sql

exit;
EOF

