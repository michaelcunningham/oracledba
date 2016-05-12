set verify off
ACCEPT sysPassword CHAR PROMPT 'Enter new password for SYS: ' HIDE
ACCEPT systemPassword CHAR PROMPT 'Enter new password for SYSTEM: ' HIDE
host /u01/app/oracle/product/12.1.0.2/dbhome_1/bin/srvctl add database -d IMDB -o /u01/app/oracle/product/12.1.0.2/dbhome_1 -p +IMDBDATA/IMDB/spfileIMDB.ora -n IMDB
host /u01/app/oracle/product/12.1.0.2/dbhome_1/bin/srvctl disable database -d IMDB
host /u01/app/oracle/product/12.1.0.2/dbhome_1/bin/orapwd file=/u01/app/oracle/product/12.1.0.2/dbhome_1/dbs/orapwIMDB force=y format=12
host /u01/app/12.1.0.2/grid/bin/setasmgidwrap o=/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/oracle
@/u01/app/oracle/admin/IMDB/scripts/CreateDB.sql
@/u01/app/oracle/admin/IMDB/scripts/CreateDBFiles.sql
@/u01/app/oracle/admin/IMDB/scripts/CreateDBCatalog.sql
host echo "SPFILE='+IMDBDATA/IMDB/spfileIMDB.ora'" > /u01/app/oracle/product/12.1.0.2/dbhome_1/dbs/initIMDB.ora
@/u01/app/oracle/admin/IMDB/scripts/lockAccount.sql
@/u01/app/oracle/admin/IMDB/scripts/postDBCreation.sql
