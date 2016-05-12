#!/bin/sh

#
# To create chained_rows table do the following.
#
# connect system
# @?/rdbms/admin/utlchain
# grant select, insert, update, delete on chained_rows to public;
#

. /dba/admin/dba.lib

if [ "$1" = "" -o "$2" = "" ]
then
  echo "Usage: $0 <ORACLE_SID> <username"
  echo "Example: $0 tdcprd novaprd"
  exit 2
else
  export ORACLE_SID=$1
  export username=$2
fi

log_date=`date +%Y%m%d`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=/dba/admin/log
log_file=$log_dir/${ORACLE_SID}_${username}_chained_rows_${log_date}.log

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus -s /nolog << EOF
connect / as sysdba
set serveroutput on size unlimited
set linesize 200
set pagesize 500
set trimspool on
set term off
set feedback off
spool $log_file

begin
	delete from system.chained_rows where owner_name = upper( '${username}' );
	commit;
	for r in(
		select	'analyze table ${username}.' || table_name || ' list chained rows into system.chained_rows' sql_text
		from	(
			select lower( table_name ) table_name from dba_tables where owner = upper( '${username}' ) and table_name not like 'MLOG$'
			minus
			select lower( table_name ) table_name from dba_external_tables where owner = upper( '${username}' ) 
			) )
	loop
--		dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
end;
/

column owner_name         format a20          	heading 'Owner'
column table_name         format a30          	heading 'Table Name'
column num_rows		  format 999,999,999	heading 'Num Rows'
column chained_row_count  format 999,999,999    heading 'Chained Row Count'
column pct_chained	  format 990.0		heading 'Pct Chained'

set linesize 100

ttitle on
ttitle center '*****  Chained Rows for $ORACLE_SID/$username  *****' skip 2

select  c.owner_name,
        c.table_name,
        t.num_rows,
        count(c.table_name) chained_row_count,
        (count(c.table_name) / decode (t.num_rows,0,1,t.num_rows)) * 100 pct_chained
from    system.chained_rows c, dba_tables t
where   c.owner_name = upper( '${username}' )
and     c.owner_name = t.owner
and     c.table_name = t.table_name
group by c.owner_name, c.table_name, t.num_rows
order by c.owner_name, c.table_name;

spool off
exit;
EOF

echo "" >> $log_file
echo "################################################################################" >> $log_file
echo "" >> $log_file
echo 'This report created by : '$0 >> $log_file
echo "" >> $log_file
echo "################################################################################" >> $log_file

mail -s "${ORACLE_SID}/${username} Chained Row Report: `date`" `cat /dba/admin/dba_team` < $log_file

