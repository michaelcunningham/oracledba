#!/bin/sh

if [ $# -ne 1 ]
then
  ORACLE_SID=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB" | sort | head -1`
  echo
  echo "        ORACLE_SID will default to: " $ORACLE_SID
  echo
  echo "        Example : $0 orcl"
  echo
  #exit 1
  else 
    export ORACLE_SID=$1
fi

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID/${log_date}_debuginfo
log_file=${log_dir}/${ORACLE_SID}_template_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_template_${log_date}.email
#mkdir -p $log_dir
#ORACLE_SID=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB" | sort | head -1`

mkdir -p $log_dir

#if [ "$1" = "" ]
#then
#  echo
#  echo "   Usage: $0 <oracle sid>"
#  echo
#  echo "   Example: $0 orcl"
#  echo
#  exit
#fi

unset SQLPATH 
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`
bdump_dir=$ORACLE_BASE/diag/rdbms/*/$ORACLE_SID/trace

mkdir -p $log_dir/bdump
echo ""
echo "Copying bdump latest files" 
echo ""
cd $bdump_dir


cp -p $(find . -maxdepth 1 -mtime -1 -type f -exec ls  {} \;) $log_dir/bdump &

#Collecting information for Oracle support

/mnt/dba/admin/collect_debug_info_2steps.sh &

#/mnt/dba/admin/collect_debug_info.sh >  $log_dir/hang_info.log
#sleep 90
#echo "sleeping 90 seconds " >> $log_dir/hang_info.log
#echo ""
#/mnt/dba/admin/collect_debug_info.sh >> $log_dir/hang_info.log

sqlplus / as sysdba <<EOF &

spool $log_dir/space_info.log

--Collect space info
@/mnt/dba/scripts/show_db_info.sql
@/mnt/dba/scripts/whoami.sql
--Tablespace info
@/mnt/dba/scripts/tbs.sql
--Datafile info
@/mnt/dba/scripts/df.sql

spool off

spool $log_dir/sessions_info.log
--Sessions
@/mnt/dba/scripts/sipa.sql
@/mnt/dba/scripts/sida.sql
@/mnt/dba/scripts/sidu.sql
@/mnt/dba/scripts/sidt.sql
@/mnt/dba/scripts/sid2.sql

spool off


spool $log_dir/show_io_info.log

@/mnt/dba/scripts/show_io_info.sql

spool off

spool $log_dir/mem_info.log
--Memory

@/mnt/dba/scripts/meminfo.sql
@/mnt/dba/scripts/pga_max.sql

spool off

spool $log_dir/redo_info.log
--redo
@/mnt/dba/scripts/redo.sql

spool off

spool $log_dir/temp_info.log

--TEMP
@/mnt/dba/scripts/shtemp.sql

spool off

spool  $log_dir/asm_info.log
--ASM
@/mnt/dba/scripts/asm_dg.sql
@/mnt/dba/scripts/asm_disks.sql

spool off
--Locks

spool $log_dir/locks.log

@/mnt/dba/scripts/shlocks.sql

spool off

EOF


/mnt/dba/admin/asm_disk_info.sh  >> $log_dir/asm_disk_info.log


## Snapshot

/mnt/dba/admin/awr_create_snapshot.sh $ORACLE_SID >> $log_dir/awr_create_snapshot.log
/mnt/dba/admin/run_awr_report_daily.sh $ORACLE_SID >> $log_dir//run_awr_report_daily.log
