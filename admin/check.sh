#!/bin/bash
# ARGS: <function> <ORACLE_SID>
ORACLE_SID=$2
export ORACLE_SID
LOG_LOC=/u01/app/oracle/admin/logs
LOG_LOC=/mnt/dba/logs/$ORACLE_SID
TS_PCT_THRESHOLD=90
ASM_WARNING_THRESHOLD=10
ASM_CRITICAL_THRESHOLD=5
ASM_FIXED_GB_THRESHOLD=600
LINE_FILE=linefile
ORA_EXCEPTIONS_FILE=ora_exceptions
ALERT_FILE=/u01/app/oracle/admin/${ORACLE_SID}/bdump/alert_${ORACLE_SID}.log
# LOGIN=`cat /u01/app/oracle/admin/common_scripts/login_system.sql `
LOGIN=system/admin123
# LOGIN_ASM=`cat /u01/app/oracle/admin/common_scripts/login_asm.sql `
LOGIN_ASM="system/admin123 as sysdba"
MAILALL="siteops@tagged.com,oncall@tagged.com"
DBAMAIL="dba@tagged.com"
TESTMAIL="dba@tagged.com"
PAGEDBA="dbaoncall@tagged.com"

export DATE=`date +%Y%m%d%k%M%S`

##################### SET ENV #############################
# check.sh is used for both local and remote checks.
# When used remote, then use the default environment (from above).
# When used locally, then use oratab.
# SET ENV LOCALLY IF ORACLE_SID IS FOUND IN ORATAB.  (WORKS FOR LISTENER check, too).
grep "^$ORACLE_SID:" /etc/oratab >/dev/null 2>&1;
if [ "$?" -eq "0" ]; then
  export PATH=/usr/local/bin:/usr/bin:/bin
  ORAENV_ASK=NO . oraenv < /dev/null > /dev/null
  export ORACLE_BASE=/u01/app/oracle;   #<-- 11g/12c oraenv might unset this for 10g homes.
else
  # Default to 10.2 EE home (mainly for dbmon04).  Later, add "DEFAULT" or "LISTENER" to oratab and then use that instead.
  export ORACLE_BASE=/u01/app/oracle
  export ORACLE_HOME=/u01/app/oracle/product/10.2
  export LD_LIBRARY_PATH=/u01/app/oracle/product/10.2/lib
  export PATH=$ORACLE_HOME/bin:/usr/local/bin:/usr/bin:/bin
fi

###########################################################
chk_oracle()
{

if [ -f ${LOG_LOC}/check_oracle_${ORACLE_SID}.lock2 ]; then
   echo "Lock file already created"
   echo "Lock file already created" | mail -s "Check.sh ${ORACLE_SID} lock file encountered" dba@tagged.com
   exit 
else
   touch ${LOG_LOC}/check_oracle_${ORACLE_SID}.lock2
fi


rm -f ${LOG_LOC}/chk_oracle_${ORACLE_SID}.log
$ORACLE_HOME/bin/sqlplus "$LOGIN"@$ORACLE_SID <<EOF 1> ${LOG_LOC}/chk_oracle_${ORACLE_SID}.log
set echo on
select 'PERFECT' from dual;
exit;
EOF
cat ${LOG_LOC}/chk_oracle_${ORACLE_SID}.log | grep "PERFECT" >/dev/null 2>&1
if [ $? -eq 1 ] ; then
# EMAIL DBA
        if [ -f ${LOG_LOC}/chk_oracle_${ORACLE_SID}.lock ]; then
            echo "Lock file already created"
        else
           touch ${LOG_LOC}/chk_oracle_${ORACLE_SID}.lock
	   cat ${LOG_LOC}/chk_oracle_${ORACLE_SID}.log >> ${LOG_LOC}/chk_oracle_problems_${ORACLE_SID}.log
           mail -s "$ORACLE_SID down" $PAGEDBA < ${LOG_LOC}/chk_oracle_${ORACLE_SID}.log
        fi
else
        rm -f ${LOG_LOC}/chk_oracle_${ORACLE_SID}.lock
fi

rm -f ${LOG_LOC}/check_oracle_${ORACLE_SID}.lock2
}

#################
# 2014-04-30 jlg: This works so long as every host has a 10.2 EE home.  Would be better to add a LISTENER entry in oratab.
chk_listener()
{
rm -f ${LOG_LOC}/chk_listener.log
lsnrctl stat <<EOF 1>>${LOG_LOC}/chk_listener.log
EOF
cat ${LOG_LOC}/chk_listener.log | grep "no listener" >/dev/null 2>&1
if [ $? -eq 0 ] ; then
    if [ -f ${LOG_LOC}/listener.lock ]; then
        echo "Listener lock file already created"
    else
        touch ${LOG_LOC}/listener.lock
        mail -s "$ORACLE_SID  Listener down" $PAGEDBA < ${LOG_LOC}/chk_listener.log
    fi
else
        rm -f ${LOG_LOC}/listener.lock
        echo "listener running" >> ${LOG_LOC}/chk_listener.log

fi
}
#################
chk_tablespace_pct()
{
rm -f ${LOG_LOC}/chk_tablespace_pct_${ORACLE_SID}.log
sqlplus ${LOGIN} <<EOF 1> ${LOG_LOC}/chk_tablespace_pct_${ORACLE_SID}.log
set pagesize 80 linesize 80
column addspace format a10
column pct_used format 99
column tablespace format a15
select 'addspace' addspace, round(100 - e.bytes/d.bytes*100 ,0) pct_used ,
       d.tablespace
from (select tablespace_name tablespace,
      sum(bytes) bytes
      from sys.dba_data_files
      group by tablespace_name ) d,
      (select tablespace_name tablespace,
       sum(bytes) bytes
       from dba_free_space
       group by tablespace_name ) e
        where d.tablespace not in ('SMAPP','SYSTEM','SYSAUX','UNDOTBS1','UNDOTBS_01') 
          and d.tablespace in (select tablespace_name from dba_tablespaces where contents='PERMANENT')
          and d.tablespace=e.tablespace and round(100 - e.bytes/d.bytes*100 ,0) > $TS_PCT_THRESHOLD
/
exit;
EOF

cat ${LOG_LOC}/chk_tablespace_pct_${ORACLE_SID}.log | grep "ORA-" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    # EMAIL DBA
    mail -s "Monitor Tablespace PCT Function Failed" $DBAMAIL < ${LOG_LOC}/chk_tablespace_pct_${ORACLE_SID}.log
else
    cat ${LOG_LOC}/chk_tablespace_pct_${ORACLE_SID}.log | grep "no rows selected" >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        # EMAIL DB
        mail -s "Adding space in $ORACLE_SID" $DBAMAIL < ${LOG_LOC}/chk_tablespace_pct_${ORACLE_SID}.log
        awk '/addspace/ {print $3}' ${LOG_LOC}/chk_tablespace_pct_${ORACLE_SID}.log > ${LOG_LOC}/addspace_$ORACLE_SID
        while read line
        do
            /u01/app/oracle/admin/common_scripts/addspace.sh $ORACLE_SID $line >> ${LOG_LOC}/chk_tablespace_pct_${ORACLE_SID}.log;
        done < ${LOG_LOC}/addspace_$ORACLE_SID
        # TODO (if problems in future): can look for "Tablespace altered." in log file.  Ignore "SP2-0734: unknown command beginning".
    else echo "Tablespace pct  function completed successfully" >> ${LOG_LOC}/chk_tablespace_pct_${ORACLE_SID}.log
    fi
fi
}
#######################
# As of 2014-04-30, these checks run locally as "check asm_pct +ASM" in crontab (they do not run remotely from dbmon04).
chk_asm_pct()
{
# 2014-04-30 jlg: should be picked up from oraenv now#  export ORACLE_HOME=/u01/app/oracle/product/11.1
rm -f ${LOG_LOC}/chk_asm_warning_${ORACLE_SID}.log
rm -f ${LOG_LOC}/chk_asm_critical_${ORACLE_SID}.log

sqlplus ${LOGIN_ASM} <<EOF 1> ${LOG_LOC}/chk_asm_warning_${ORACLE_SID}.log
select usable_file_mb, round((usable_file_mb/total_mb)*100,2) pct_free, name from
(select usable_file_mb, total_mb, name from v\$asm_diskgroup where state='MOUNTED')
where  round((usable_file_mb/total_mb)*100,2) <  $ASM_WARNING_THRESHOLD 
and usable_file_mb < $ASM_FIXED_GB_THRESHOLD * 1024
/	
exit;
EOF

sqlplus ${LOGIN_ASM} <<EOF 1> ${LOG_LOC}/chk_asm_critical_${ORACLE_SID}.log
select usable_file_mb, round((usable_file_mb/total_mb)*100,2) pct_free, name from
(select usable_file_mb, total_mb, name from v\$asm_diskgroup where state='MOUNTED')
where  round((usable_file_mb/total_mb)*100,2) <  $ASM_CRITICAL_THRESHOLD
and usable_file_mb < $ASM_FIXED_GB_THRESHOLD * 1024
/
exit;
EOF

cat ${LOG_LOC}/chk_asm_warning_${ORACLE_SID}.log | grep "ORA-" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    # EMAIL DBA
    mail -s "ASM PCT Function Failed" $DBAMAIL < ${LOG_LOC}/chk_asm_warning_${ORACLE_SID}.log
else
    cat ${LOG_LOC}/chk_asm_warning_${ORACLE_SID}.log | grep "no rows selected" >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        # EMAIL DBA
        mail  -s "WARNING:ASM approach PCT Threshold in $ORACLE_SID" $DBAMAIL < ${LOG_LOC}/chk_asm_warning_${ORACLE_SID}.log
    #else echo "ASM pct function completed successfully"
    fi
fi

cat ${LOG_LOC}/chk_asm_critical_${ORACLE_SID}.log | grep "ORA-" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    # EMAIL DBA
    mail -s "ASM PCT Function Failed" $DBAMAIL < ${LOG_LOC}/chk_asm_critical_${ORACLE_SID}.log
else
    cat ${LOG_LOC}/chk_asm_critical_${ORACLE_SID}.log | grep "no rows selected" >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        # EMAIL DBA
        mail  -s "CRITICAL:ASM approach PCT Threshold in $ORACLE_SID" $PAGEDBA < ${LOG_LOC}/chk_asm_critical_${ORACLE_SID}.log
    #else echo "ASM pct function completed successfully"
    fi
fi

}
#####################
# As of 2014-04-30, these reports run locally as "check asm +ASM" in crontab (they do not run remotely from dbmon04).
asm_storage_report()
{
rm -f ${LOG_LOC}/storage_report_${ORACLE_SID}.log
# 2014-04-30 jlg: should be picked up from oraenv now#  export ORACLE_HOME=/u01/app/oracle/product/11.1
sqlplus ${LOGIN_ASM} <<EOF 1> ${LOG_LOC}/storage_report_${ORACLE_SID}.log
@/mnt/dba/scripts/asm_space_used.sql
exit;
EOF
mail -s "ASM Storage report" $DBAMAIL < ${LOG_LOC}/storage_report_${ORACLE_SID}.log
}
####################

chk_alert()
{
    
# Description: This function looks into alert file of oracle & reports
#             all matches to ORA- pattern thru e-mail.
#              It also pages ODBA.

#Input: $LINE_FILE that stores line_no from where to start search
#Output: A mail containing all ORA- messages. Resets the $PARFILE with the
#        current no. of lines.

# if [ -f $LINE_FILE ] ; then
# from_line=`cat $LINE_FILE`
# if [ "$from_line" = "" ] ; then
    from_line=1
#fi
#else
#  from_line=1
#fi
if [ ! -f $ORA_EXCEPTIONS_FILE ] ; then
    touch $ORA_EXCEPTIONS_FILE
fi
rm -f $LOG_LOC/diffs_${ORACLE_SID}
# cur_lines=`wc -l $ALERT_FILE|cut -f1 -d' '`
# If the $cur_lines is less than the last line the script looked at last,
# it probably means that the alert.log file has been cycled. So assume
# that the file has not been read from and set $from_line = 1
# if [ $cur_lines -lt $from_line ] ; then
    from_line=1
# fi
# if [ $from_line -ne $cur_lines ] ; then
    rm -f $LOG_LOC/chk_alert_${ORACLE_SID}.log
    tail $ALERT_FILE| grep "ORA-" > $LOG_LOC/chk_alert_${ORACLE_SID}.log
    if [ $LOG_LOC/chk_alert_${ORACLE_SID}.log ] ; then
        rm -f $LOG_LOC/alert_chk_${ORACLE_SID}.non600.log $LOG_LOC/alert_chk_${ORACLE_SID}.600.log $LOG_LOC/alert_except_${ORACLE_SID}.600.log $LOG_LOC/alert_except_${ORACLE_SID}.non600.log $LOG_LOC/alert_except_${ORACLE_SID}.disttrans.log

        cat $LOG_LOC/chk_alert_${ORACLE_SID}.log| grep "ORA-" | grep -v "ORA-00600" | awk -F"[: ]" '{print $1}' | sort | uniq > $LOG_LOC/alert_chk_${ORACLE_SID}.non600.log
	cat $LOG_LOC/chk_alert_${ORACLE_SID}.log| grep "ORA-00600" | awk -F": " '{print $1, $3}' | awk -F"," '{print $1}' | sort | uniq > $LOG_LOC/alert_chk_${ORACLE_SID}.600.log

	cat $LOG_LOC/chk_alert_${ORACLE_SID}.log| grep "DISTRIB TRAN" | sort > $LOG_LOC/alert_${ORACLE_SID}.distsort.log
	cat $LOG_LOC/alert_${ORACLE_SID}.distsort.log | uniq > $LOG_LOC/alert_${ORACLE_SID}.distuniq.log

        cat ${ORA_EXCEPTIONS_FILE} | grep ORA-00600 | awk '{print $1, $2}' | sort | uniq > $LOG_LOC/alert_except_${ORACLE_SID}.600.log
	cat ${ORA_EXCEPTIONS_FILE} | grep -v ORA-00600 | sort | uniq > $LOG_LOC/alert_except_${ORACLE_SID}.non600.log

	comm -23 $LOG_LOC/alert_chk_${ORACLE_SID}.non600.log $LOG_LOC/alert_except_${ORACLE_SID}.non600.log > $LOG_LOC/diffs_${ORACLE_SID}
	comm -23 $LOG_LOC/alert_chk_${ORACLE_SID}.600.log $LOG_LOC/alert_except_${ORACLE_SID}.600.log >> $LOG_LOC/diffs_${ORACLE_SID}
	if [ -f $LOG_LOC/alert_${ORACLE_SID}.distsort.log ] ; then
	cat $LOG_LOC/alert_${ORACLE_SID}.distuniq.log | while read file
	do
	DIST_TRANS=`echo $file`
	[ `grep -c "${DIST_TRANS}" $LOG_LOC/alert_${ORACLE_SID}.distsort.log` -lt 3 ] && echo $file >> $LOG_LOC/diffs_${ORACLE_SID}
	done
	fi
	mail -s "Error Messages in alert file $ALERT_FILE" $DBAMAIL < ${LOG_LOC}/chk_alert_${ORACLE_SID}.log
	no_of_diffs=`cat ${LOG_LOC}/diffs_${ORACLE_SID} | wc -l`
	if [ $no_of_diffs -ne 0 ] ; then
        if [ "${PAGEDBA_ALERT}" = "YES" ] ; then 
	cat $LOG_LOC/chk_alert_${ORACLE_SID}.log | sort | uniq | while read Msgtext
	do
	mail -s "$ORACLE_SID alrt" $MAILALL < ${Msgtext}
#        ${NOTIFY} -r dba@tagged.com -s ${ORACLE_SID} -l "PAGER" -n "alert" -m "${Msgtext}"
	done
        fi
	fi
    fi
    echo $cur_lines >$LINE_FILE
# fi
}
run_perfstat()
{
$ORACLE_HOME/bin/sqlplus -s /NOLOG <<EOF 1> ${LOG_LOC}/perfstat_${ORACLE_SID}.log
connect perfstat/perfstat@$ORACLE_SID
alter session set timed_statistics = true; 
execute statspack.snap (I_SNAP_LEVEL=>5);
exit;
EOF
}
run_perfstat_purge()
{
$ORACLE_HOME/bin/sqlplus -s /NOLOG <<EOF 1> ${LOG_LOC}/perfstat_purge_${ORACLE_SID}.log
connect perfstat/perfstat@$ORACLE_SID
alter session set timed_statistics = true; 
exec perfstat.statspack.purge(i_num_days => 30, i_extended_purge => TRUE);
exit;
EOF
}
add_tbs()
{
$ORACLE_HOME/bin/sqlplus "$LOGIN"@$ORACLE_SID <<EOF 1> ${LOG_LOC}/add_tbs${ORACLE_SID}.log
@/u01/app/oracle/admin/$ORACLE_SID/create/crtbs1.sql
EOF
}
# *****************
test_page()
{
$ORACLE_HOME/bin/sqlplus "$LOGIN"@$ORACLE_SID <<EOF 1> ${LOG_LOC}/test_page_${ORACLE_SID}.log
@test.sql
EOF
cat ${LOG_LOC}/test_page_${ORACLE_SID}.log | grep "tello" >/dev/null 2>&1
if [ $? -eq 1 ] ; then
# EMAIL DBA
        if [ -f ${LOG_LOC}/test_page_${ORACLE_SID}.lock ]; then
            echo "Lock file already created"
        else
           touch ${LOG_LOC}/test_page_${ORACLE_SID}.lock
        mail -s "$ORACLE_SID test" $TESTMAIL < ${LOG_LOC}/test_page_${ORACLE_SID}.log
        fi
else
        rm -f ${LOG_LOC}/test_page_${ORACLE_SID}.lock
fi

}

# *****************


# 2014-04-30 jlg: adding "asm_storage_report" as another way to call asm_storage_report() so that the cronjob is more obvious.
case $1 in
  "oracle")
    chk_oracle;;
  "listener")
    chk_listener;;
  "asm_pct")
    chk_asm_pct;;
  "tablespace_pct")
    chk_tablespace_pct;;
  "asm" | "asm_storage_report")
    asm_storage_report;;
  "test_page")
    test_page;;
  "add_tbs")
    add_tbs;;
  "perfstat")
    run_perfstat;;
  "perfstat_purge")
    run_perfstat_purge;;
esac;

