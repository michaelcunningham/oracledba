#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage: $0 <ORACLE_SID>"
  echo
  echo "        Example: $0 tdcdw"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/drop_dbms_jobs_$log_date.log

summary_file=$log_dir/drop_dbms_jobs_summary_$log_date.log
node_name=`hostname | awk -F . '{print $1}'`

> $summary_file
> $log_file

sqlplus -s /nolog << EOF
connect fpicusr/fpicusr

set serveroutput on
set feedback off
spool $log_file
declare
        s_sql           varchar2(200);
begin
        for r in (
                 select s.job from user_jobs s )
       loop 
       s_sql := 'exec dbms_job.remove('||r.job||');' ;
       dbms_output.put_line( s_sql );
        --execute immediate s_sql;
        --dbms_lock.sleep(3);
        end loop;
end;
/
spool off
@$log_file
exit;
EOF
