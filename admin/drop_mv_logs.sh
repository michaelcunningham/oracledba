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
log_file=$log_dir/drop_mv_logs_$log_date.log

. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
starusername=ora\$prd
staruserpwd=`get_user_pwd $tns $starusername`
vistausername=vistaprd
vistauserpwd=`get_user_pwd $tns $vistausername`

sqlplus -s /nolog << EOF > $log_file
connect $starusername/$staruserpwd
DECLARE
        CURSOR cur_drop IS
                SELECT  DISTINCT 'drop materialized view log on ' || master AS sql_text
                FROM    user_snapshot_logs;
        s_sql   VARCHAR2(200);
BEGIN
        FOR r IN cur_drop LOOP
                s_sql := r.sql_text;
                EXECUTE IMMEDIATE s_sql;
        END LOOP;
END;
/

connect $vistausername/$vistauserpwd
DECLARE
        CURSOR cur_drop IS
                SELECT  DISTINCT 'drop materialized view log on ' || master AS sql_text
                FROM    user_snapshot_logs;
        s_sql   VARCHAR2(200);
BEGIN
        FOR r IN cur_drop LOOP
                s_sql := r.sql_text;
                EXECUTE IMMEDIATE s_sql;
        END LOOP;
END;
/
exit;
EOF

