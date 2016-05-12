#!/bin/sh

SRC_DB=$1
TARGET_DB=$2
HOSTNAME=`hostname | cut -d. -f1`
LOGDIR="/mnt/dba/logs/"
LOGFILE="${LOGDIR}${HOSTNAME}_chk_db_flashback.log"
LOGIN="system/admin123"

createDirStructure() {
   echo "sudo mkdir /u02"
   sudo mkdir /u02

   echo "sudo chown oracle:dba /u02"
   sudo chown oracle:dba /u02

   echo "mkdir -p /u01/app/oracle/admin/$TARGET_DB/adump"
   mkdir -p "/u01/app/oracle/admin/$TARGET_DB/adump"

   echo "mkdir -p /u02/oradata/$TARGET_DB/data"
   mkdir -p "/u02/oradata/$TARGET_DB/data"

   echo " mkdir -p /u02/oradata/$TARGET_DB/ctl"
   mkdir -p "/u02/oradata/$TARGET_DB/ctl"

   echo "mkdir -p /u02/oradata/$TARGET_DB/redo"
   mkdir -p "/u02/oradata/$TARGET_DB/redo"

   echo "mkdir -p /u02/oradata/$TARGET_DB/arch"
   mkdir -p "/u02/oradata/$TARGET_DB/arch"

   echo "mkdir -p /mnt/db_transfer/$TARGET_DB/arch_backup"
   mkdir -p /mnt/db_transfer/$TARGET_DB/arch_backup

   echo "kdir -p /mnt/db_transfer/$TARGET_DB/rman_backup"
   mkdir -p /mnt/db_transfer/$TARGET_DB/rman_backup

   echo "mkdir -p /mnt/db_transfer/$TARGET_DB/logs"
   mkdir -p /mnt/db_transfer/$TARGET_DB/logs
}

createInitOra(){
    initOra=
    echo "${TARGET_DB}.__db_cache_size=855638016" > $initOra
    echo "${TARGET_DB}.__java_pool_size=4194304" >> $initOra
    echo "${TARGET_DB}.__large_pool_size=4194304" >> $initOra
    echo "${TARGET_DB}.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment" >> $initOra
    echo "${TARGET_DB}.__shared_pool_size=654311424" >> $initOra
    echo "${TARGET_DB}.__streams_pool_size=16777216" >> $initOra
    echo "*.archive_lag_target=0" >> $initOra
    echo "*.audit_file_dest='/u01/app/oracle/admin/${TARGET_DB}/adump'" >> $initOra
    echo "*.compatible='12.1.0.1.0'" >> $initOra
    echo "*.control_files='/u02/oradata/${TARGET_DB}/ctl/control01.ctl','/u02/oradata/${TARGET_DB}/ctl/control02.ctl'#Restore Controlfile" >> $initOra
    echo "*.db_block_size=8192" >> $initOra
    echo "*.db_cache_advice='ON'" >> $initOra
    echo "*.db_cache_size=1056964608" >> $initOra
    echo "${TARGET_DB}.db_cache_size=989855744" >> $initOra
    echo "*.db_domain=''" >> $initOra
    echo "*.db_name='${TARGET_DB}'" >> $initOra
    echo "*.db_unique_name='${TARGET_DB}B'" >> $initOra
    echo "*.dg_broker_start=TRUE" >> $initOra
    echo "*.diagnostic_dest='/u01/app/oracle'" >> $initOra
    echo "*.dispatchers='(PROTOCOL=TCP) (SERVICE=${TARGET_DB}XDB)'" >> $initOra
    echo "*.fal_client='${TARGET_DB}A'" >> $initOra
    echo "*.fal_server='${TARGET_DB}B'" >> $initOra
    echo "*.java_pool_size=57671680" >> $initOra
    echo "*.large_pool_size=16777216" >> $initOra
    echo "*.log_archive_config='dg_config=(${TARGET_DB}A,stgprt02B)'" >> $initOra
    echo "*.log_archive_dest_1='location=/u02/oradata/${TARGET_DB}/arch'" >> $initOra
    echo "*.log_archive_dest_state_2='ENABLE'" >> $initOra
    echo "${TARGET_DB}.log_archive_format='%t_%s_%r.dbf'" >> $initOra
    echo "*.log_archive_max_processes=4" >> $initOra
    echo "*.log_archive_min_succeed_dest=1" >> $initOra
    echo "${TARGET_DB}.log_archive_trace=0" >> $initOra
    echo "*.open_cursors=300" >> $initOra
    echo "*.pga_aggregate_target=400M" >> $initOra
    echo "*.processes=1000" >> $initOra
    echo "*.remote_login_passwordfile='EXCLUSIVE'" >> $initOra
    echo "*.service_names='${TARGET_DB}, ${TARGET_DB}A'" >> $initOra
    echo "*.session_cached_cursors=20" >> $initOra
    echo "*.session_max_open_files=20" >> $initOra
    echo "*.sessions=555" >> $initOra
    echo "*.sga_max_size=2621440000" >> $initOra
    echo "*.sga_target=0" >> $initOra
    echo "*.shared_pool_size=536870912" >> $initOra
    echo "*.standby_file_management='AUTO'" >> $initOra
    echo "${TARGET_DB}.streams_pool_size=67108864" >> $initOra
    echo "*.undo_management='AUTO'" >> $initOra
    echo "*.undo_tablespace='UNDOTBS1" >> $initOra
}
buildExpCmd(){
   export ORACLE_SID=$SRC_DB
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

}

createDirStructure;

