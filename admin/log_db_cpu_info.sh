#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

instance_name=$1

####################################################################################################
#
# Create the database link for the DMMASTER database.
#
####################################################################################################
db_cpu=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba

select round( value / 1000000 ) db_cpu from v\\$sys_time_model where stat_name = 'DB CPU';

exit;
EOF`

db_cpu=`echo $db_cpu`

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=dmmaster
userpwd=dm7master

####################################################################################################
#
# Record the CPU Time.
#
####################################################################################################
sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

declare
begin
	merge into db_cpu_info t
	using (
		select	'$instance_name' instance_name,
			trunc(sysdate) collection_date,
			'$db_cpu' cpu_seconds
		from	dual ) s
	on	( t.instance_name = s.instance_name and t.collection_date = s.collection_date )
	when matched then
		update
		set	cpu_seconds = s.cpu_seconds
	when not matched then insert(
			instance_name, collection_date, cpu_seconds )
		values(
			'$instance_name', s.collection_date, s.cpu_seconds );
	commit;

end;
/

exit;
EOF
