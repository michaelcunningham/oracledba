--
-- Run as SYS in source database (DV3).
--
exec dbms_tts.transport_set_check('apc_data', true);

-- Check that all is ok.
select * from transport_set_violations;


--
-- Run as SYS in source database.
-- NOTE: This is best run from a Linux shell prompt
--
-- The following is in the script named:
--
--	/oracle/app/oracle/admin/tdcdba/adhoc/prep_transport.sh
--
sqlplus /nolog << EOF
connect / as sysdba
alter tablespace apc_data read only;
exit;
EOF

exp userid=\"/ as sysdba\" transport_tablespace=y \
tablespaces=apc_data \
statistics=none triggers=n constraints=y grants=y file=/${ORACLE_SID}/backup_files/transport_ap.dmp

rsh npnetapp103 snap delete $ORACLE_SID transport_ap.1
rsh npnetapp103 snap create $ORACLE_SID transport_ap.1

sqlplus /nolog << EOF
connect / as sysdba
alter tablespace apc_data read write;
exit;
EOF

--
-- Export the necessary stats for all the schemas being transported.
--
/dba/transport/stats_create_stats_table.sh tdcdba ap_decrypt_tables
/dba/transport/stats_create_stats_table.sh tdcdba ap_ods_policy
/dba/transport/stats_create_stats_table.sh tdcdba ap_edw_datamart
/dba/transport/stats_create_stats_table.sh tdcdba ap_as400
/dba/transport/stats_create_stats_table.sh tdcdba ap_dw_v2
/dba/transport/stats_create_stats_table.sh tdcdba ap_text
/dba/transport/stats_create_stats_table.sh tdcdba ap_wynsure
/dba/transport/stats_create_stats_table.sh tdcdba ap_nova_int
/dba/transport/stats_create_stats_table.sh tdcdba ap_unix

/dba/transport/stats_export_schema_stats.sh tdcdba ap_decrypt_tables transport_01
/dba/transport/stats_export_schema_stats.sh tdcdba ap_ods_policy transport_01
/dba/transport/stats_export_schema_stats.sh tdcdba ap_edw_datamart transport_01
/dba/transport/stats_export_schema_stats.sh tdcdba ap_as400 transport_01
/dba/transport/stats_export_schema_stats.sh tdcdba ap_dw_v2 transport_01
/dba/transport/stats_export_schema_stats.sh tdcdba ap_text transport_01
/dba/transport/stats_export_schema_stats.sh tdcdba ap_wynsure transport_01
/dba/transport/stats_export_schema_stats.sh tdcdba ap_nova_int transport_01
/dba/transport/stats_export_schema_stats.sh tdcdba ap_unix transport_01

/dba/transport/stats_export_stats_table.sh tdcdba ap_decrypt_tables ap_decrypt_tables_01
/dba/transport/stats_export_stats_table.sh tdcdba ap_ods_policy ap_ods_policy_01
/dba/transport/stats_export_stats_table.sh tdcdba ap_edw_datamart ap_edw_datamart_01
/dba/transport/stats_export_stats_table.sh tdcdba ap_as400 ap_as400_01
/dba/transport/stats_export_stats_table.sh tdcdba ap_dw_v2 ap_dw_v2_01
/dba/transport/stats_export_stats_table.sh tdcdba ap_text ap_text_01
/dba/transport/stats_export_stats_table.sh tdcdba ap_wynsure ap_wynsure_01
/dba/transport/stats_export_stats_table.sh tdcdba ap_nova_int ap_nova_int_01
/dba/transport/stats_export_stats_table.sh tdcdba ap_unix ap_unix_01


--
-- In case the transport has already been performed once and we are running
-- it again then this is necessary in the target database.
--
/oracle/app/oracle/admin/tdcdv2/create/create_all_ap.sh


--
-- Now we need to copy the data files.
-- This is hard coded for now, but could be automated if needed.
--
-- The following is in the script named:
--
--	/oracle/app/oracle/admin/tdcdv2/adhoc/pull_transport_files.sh

***** DROP DESTINATION TABLESPACES 
--
scp npdb550:/tdcdba/.snapshot/transport_ap.1/oradata/apc_data01.dbf /tdcdv2/oradata/apc_data01.dbf
scp npdb550:/tdcdba/.snapshot/transport_ap.1/oradata/apc_data02.dbf /tdcdv2/oradata/apc_data02.dbf
scp npdb550:/tdcdba/.snapshot/transport_ap.1/oradata/apc_data03.dbf /tdcdv2/oradata/apc_data03.dbf
scp npdb550:/tdcdba/backup_files/transport_ap.dmp /tdcdv2/backup_files/transport_ap.dmp

--
-- Run as SYS in target database.
--
--/oracle/app/oracle/admin/tdcdv2/create/create_all_ap.sh
/oracle/app/oracle/admin/tdcdv2/create/alter_ap_users_apc_data.sql

--
-- Run as SYS in target database.
-- NOTE: This is best run from a Linux shell prompt
--
-- Script name: /oracle/app/oracle/admin/tdcdv2/adhoc/imp_transport.sh
--
imp userid=\"/ as sysdba\" transport_tablespace=y \
datafiles='/tdcdv2/oradata/apc_data01.dbf', '/tdcdv2/oradata/apc_data02.dbf, /tdcdv2/oradata/apc_data03.dbf' \
file=/tdcdv2/backup_files/transport_ap.dmp

sqlplus /nolog << EOF
connect / as sysdba
alter tablespace apc_data read write;
exit;
EOF

/oracle/app/oracle/admin/tdcdv2/create/alter_ap_users_apc_data_ts.sh


-- The following read/write commands are not necessary, but shown here to indicate
-- the tablespaces will be read only at this stage.
-- alter tablespace ttbs read write;
-- alter tablespace ttbsix read write;

--
-- At this point the tablespaces are imported, but they do not have any stats.
-- We need to import the stats.
--
/dba/transport/stats_create_stats_table.sh tdcdv2 ap_decrypt_tables
/dba/transport/stats_create_stats_table.sh tdcdv2 ap_ods_policy
/dba/transport/stats_create_stats_table.sh tdcdv2 ap_edw_datamart
/dba/transport/stats_create_stats_table.sh tdcdv2 ap_as400
/dba/transport/stats_create_stats_table.sh tdcdv2 ap_dw_v2
/dba/transport/stats_create_stats_table.sh tdcdv2 ap_text
/dba/transport/stats_create_stats_table.sh tdcdv2 ap_wynsure
/dba/transport/stats_create_stats_table.sh tdcdv2 ap_nova_int
/dba/transport/stats_create_stats_table.sh tdcdv2 ap_unix

/dba/transport/stats_import_stats_table.sh tdcdv2 ap_decrypt_tables ap_decrypt_tables_01
/dba/transport/stats_import_stats_table.sh tdcdv2 ap_ods_policy ap_ods_policy_01
/dba/transport/stats_import_stats_table.sh tdcdv2 ap_edw_datamart ap_edw_datamart_01
/dba/transport/stats_import_stats_table.sh tdcdv2 ap_as400 ap_as400_01
/dba/transport/stats_import_stats_table.sh tdcdv2 ap_dw_v2 ap_dw_v2_01
/dba/transport/stats_import_stats_table.sh tdcdv2 ap_text ap_text_01
/dba/transport/stats_import_stats_table.sh tdcdv2 ap_wynsure ap_wynsure_01
/dba/transport/stats_import_stats_table.sh tdcdv2 ap_nova_int ap_nova_int_01
/dba/transport/stats_import_stats_table.sh tdcdv2 ap_unix ap_unix_01

/dba/transport/stats_import_schema_stats.sh tdcdv2 ap_decrypt_tables transport_01
/dba/transport/stats_import_schema_stats.sh tdcdv2 ap_ods_policy transport_01
/dba/transport/stats_import_schema_stats.sh tdcdv2 ap_edw_datamart transport_01
/dba/transport/stats_import_schema_stats.sh tdcdv2 ap_as400 transport_01
/dba/transport/stats_import_schema_stats.sh tdcdv2 ap_dw_v2 transport_01
/dba/transport/stats_import_schema_stats.sh tdcdv2 ap_text transport_01
/dba/transport/stats_import_schema_stats.sh tdcdv2 ap_wynsure transport_01
/dba/transport/stats_import_schema_stats.sh tdcdv2 ap_nova_int transport_01
/dba/transport/stats_import_schema_stats.sh tdcdv2 ap_unix transport_01


