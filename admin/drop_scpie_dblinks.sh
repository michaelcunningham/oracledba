#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 tdccpy"
  echo
  exit
fi

export ORACLE_SID=$1

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/drop_scpie_dblinks_$log_date.log

. /dba/admin/dba.lib

sqlplus -s /nolog << EOF >> $log_file
connect sccommon/sccommon
declare
	s_sql   varchar2(200);
begin
	for r in ( select db_link from user_db_links ) loop
		s_sql := 'drop database link ' || r.db_link;
		dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/

connect sctdcref/sctdcref
declare
	s_sql   varchar2(200);
begin
	for r in ( select db_link from user_db_links ) loop
		s_sql := 'drop database link ' || r.db_link;
		dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/

connect scwins/scwins
declare
	s_sql   varchar2(200);
begin
	for r in ( select db_link from user_db_links ) loop
		s_sql := 'drop database link ' || r.db_link;
		dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/

connect scmga/scmga
declare
	s_sql   varchar2(200);
begin
	for r in ( select db_link from user_db_links ) loop
		s_sql := 'drop database link ' || r.db_link;
		dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/

connect scska/scska
declare
	s_sql   varchar2(200);
begin
	for r in ( select db_link from user_db_links ) loop
		s_sql := 'drop database link ' || r.db_link;
		dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/
exit;
EOF

