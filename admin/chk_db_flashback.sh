#!/bin/sh


DBAEMAIL="vadim@tagged.com"
HOSTNAME=`hostname | cut -d. -f1`
LOGDIR="/mnt/dba/logs/"
LOGFILE="${LOGDIR}${HOSTNAME}_chk_db_flashback.log"
ACTUAL_FLASHBACK_SIZE=0
ESTIMATED_FLASHBACK_SIZE=0
ASM_DISKGROUP_SIZE=0
ASM_DISK_GROUP='FRA'
LOGIN="system/admin123"
FAILED=0

function get_db_flashback_space(){

   export ORACLE_SID=$1
   unset SQLPATH
   export PATH=/usr/local/bin:$PATH
   ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqloutput=`sqlplus -s system/admin123 as sysdba <<EOF
set heading off
set echo off
set serveroutput on
declare
    isEnabled                VARCHAR2(4);
    asmTotalBytes            VARCHAR2(200);
    asmTotalMB               NUMBER(20,0);
    asmDiskGroupName         VARCHAR2(50):= '$ASM_DISK_GROUP'; 
    flashbackActualSize      VARCHAR2(200);
    flashbackEstimated       VARCHAR2(200);
    flashbackDestSize        VARCHAR2(200);
begin
  SELECT FLASHBACK_ON
  INTO isEnabled 
  FROM V\\$DATABASE;
  IF upper(isEnabled) = 'NO'
  THEN
      DBMS_OUTPUT.PUT_LINE('NO,0,0,0,0');      
      RETURN;
  END IF;
  
  select TOTAL_MB
  into asmTotalMB 
  from v\\$asm_diskgroup 
  where name = upper(asmDiskGroupName);

  select to_char(value) into flashbackDestSize from v\\$parameter where name = 'db_recovery_file_dest_size';
  
  select to_char((asmTotalMB * 1024 * 1024))
  into asmTotalBytes
  from dual;
  
  SELECT TO_CHAR(FLASHBACK_SIZE), TO_CHAR(ESTIMATED_FLASHBACK_SIZE)
  INTO flashbackActualSize, flashbackEstimated
  FROM v\\$flashback_database_log;
  
  DBMS_OUTPUT.PUT_LINE('YES,' || asmTotalBytes ||',' || flashbackActualSize || ','|| flashbackEstimated || ','|| flashbackDestSize);

end;
/
exit;
EOF
`

sqloutput=$(sed -e 's/ PL\/SQL procedure successfully completed\.$//' <<<$sqloutput)
echo $sqloutput

}

function get_total_flashback_space(){
    for entry in `cat /etc/oratab | grep -v \^$ | grep -v \^# | grep -v \* | cut -d: -f1-2`
    do
        DB=`echo $entry | cut -d: -f1`
        FOLDER=`echo $entry | cut -d: -f2`
        if [ $DB == "+ASM" ]
        then
            continue;
        fi
        statsString=$(get_db_flashback_space $DB );
        #splitting string
        statsString=$(echo $statsString |  awk -F"," '{print $1,$2,$3,$4,$5}');
        set -- $statsString

        flashbackEnabled=$1
        
        if [ $flashbackEnabled = "YES" ]
        then
            ASM_DISKGROUP_SIZE=$2;
            flashbackActualSize=$3;
            flashbackEstimated=$4
            flashbackDestSize=$5

            if [ $flashbackDestSize -le $flashbackEstimated ]
            then
                FAILED=1
                echo "${DB} Allocated Flashback space is not sufficient. Allocated: $flashbackDestSize bytes Actual: ${flashbackActualSize} bytes  Estimated: ${flashbackEstimated} bytes" >> "${LOGFILE}"
            fi
       
            ACTUAL_FLASHBACK_SIZE=$(($ACTUAL_FLASHBACK_SIZE+$flashbackActualSize))
            ESTIMATED_FLASHBACK_SIZE=$(($ESTIMATED_FLASHBACK_SIZE+$flashbackEstimated)) 
        else 
            FAILED=2
            echo "${DB} Flashback is not enabled"  >> "${LOGFILE}"
            continue;
        fi
    done
 
    
    # if flashback is enabled
    if [ $ESTIMATED_FLASHBACK_SIZE -eq 0 ] || [ $ASM_DISKGROUP_SIZE -eq 0 ]
    then
       FAILED=2
       echo "Unable to determmen flashback space " >> "${LOGFILE}"
    else

       if [ $ESTIMATED_FLASHBACK_SIZE -ge $ASM_DISKGROUP_SIZE ] 
       then
           FAILED=1
           echo "${HOSTNAME} does not have sufficient space to store flashback data. ASM SPACE: ${ASM_DISKGROUP_SIZE} bytes  Estimated: ${ESTIMATED_FLASHBACK_SIZE} bytes" >> "${LOGFILE}"
       fi
   fi 
}

echo "" > ${LOGFILE}

if [ ! -f '/etc/oratab' ]
then
   exit 0;
fi

get_total_flashback_space ;
if [ $FAILED -eq 1 ]
then
    mail -s "FLASHBACK CHECK FOR $HOSTNAME FAIL " $DBAEMAIL < ${LOGFILE}
    exit 1
fi
exit 0;
