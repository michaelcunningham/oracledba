#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "	Usage: $0 <tns> <username>"
  echo
  echo "	Example: $0 tdccv1 novaprd"
  echo
  exit
fi

export tns=$1
export username=$2
. /dba/admin/dba.lib

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_file=$log_dir/kill_all_user_$log_date.log

syspwd=`get_sys_pwd $tns`

sqlplus -s /nolog << EOF
connect sys/$syspwd@$tns as sysdba

set serveroutput on
prompt

declare
--	n_sid		number;
--	n_serial	number;
	s_sql		varchar2(100);
begin
	for r in(
		select  s.sid, s.serial#
		from    v\$session s
		where   s.username = upper( '$username' ) )
	loop
		s_sql := 'alter system disconnect session ''' || r.sid || ',' || r.serial# || ''' immediate';
		dbms_output.put_line( s_sql );

		execute immediate s_sql;
	end loop;
exception
	when no_data_found then
		null;
end;
/

exit;
EOF

