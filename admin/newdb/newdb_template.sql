set verify off
ACCEPT sysPassword CHAR PROMPT 'Enter new password for SYS: ' HIDE
ACCEPT systemPassword CHAR PROMPT 'Enter new password for SYSTEM: ' HIDE

host /u01/app/oracle/product/12.1.0/dbhome_1/bin/orapwd file=/u01/app/oracle/product/12.1.0/dbhome_1/dbs/orapwdb_name_template force=y format=12
host /u01/app/12.1.0/grid/bin/setasmgidwrap o=/u01/app/oracle/product/12.1.0/dbhome_1/bin/oracle

@/u01/app/oracle/admin/db_name_template/scripts/CreateDB.sql
@/u01/app/oracle/admin/db_name_template/scripts/CreateDBFiles.sql
@/u01/app/oracle/admin/db_name_template/scripts/CreateDBCatalog.sql

host /u01/app/oracle/product/12.1.0/dbhome_1/bin/srvctl add database -db db_name_templatea -dbname db_name_template -instance db_name_template -oraclehome /u01/app/oracle/product/12.1.0/dbhome_1 -spfile +/u01/app/oracle/product/12.1.0/dbhome_1/dbs/spfiledb_name_template.ora -diskgroup "DATA,LOG"

# host echo "SPFILE='+DATA/db_name_template/spfiledb_name_template.ora'" > /u01/app/oracle/product/12.1.0/dbhome_1/dbs/initdb_name_template.ora

@/u01/app/oracle/admin/db_name_template/scripts/lockAccount.sql
@/u01/app/oracle/admin/db_name_template/scripts/postDBCreation.sql
