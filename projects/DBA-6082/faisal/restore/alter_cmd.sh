#!/bin/sh

export ORACLE_SID=STGPRT03
export TARGET2_SID=SPDB03
export TARGET_SID=SPDB07


sqlplus / as sysdba << EOF

spool /mnt/db_transfer/SPDB07/alter_cmd.log

alter system set db_create_online_log_dest_1 = '/u02/oradata/${TARGET_SID}/redo';
alter system set db_create_file_dest = '/u02/oradata/${TARGET_SID}/data';
alter system set db_name='${ORACLE_SID}' scope=spfile;
alter system set db_unique_name='${ORACLE_SID}C' scope=spfile;
ALTER SYSTEM SET log_file_name_convert='/noop/','/noop/' SCOPE=SPFILE;
ALTER SYSTEM SET db_file_name_convert='/noop/','/noop/' SCOPE=SPFILE;
alter system set archive_lag_target=900;
alter system set service_names='${ORACLE_SID}','${ORACLE_SID}C';
alter system set log_archive_dest_1='location=/u02/oradata/${TARGET_SID}/arch';
alter system set log_archive_dest_state_1=enable;
alter system set control_files='/u02/oradata/${TARGET_SID}/ctl/control01.ctl','/u02/oradata/${TARGET_SID}/ctl/control02.ctl','/u02/oradata/${TARGET_SID}/ctl/control03.ctl' scope=spfile;
alter system set db_create_file_dest = '/u02/oradata/${TARGET_SID}/data';
alter system set db_create_online_log_dest_1 = '/u02/oradata/${TARGET_SID}/redo';
alter system set fal_client='';
alter system set fal_server='';
alter system set log_archive_dest_2='';
alter system set log_archive_dest_state_2=defer;
shutdown immediate;
spool off
exit;
EOF
