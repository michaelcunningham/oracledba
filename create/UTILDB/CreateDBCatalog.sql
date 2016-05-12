SET VERIFY OFF
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /u01/app/oracle/admin/IMDB/scripts/CreateDBCatalog.log append
@/u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/admin/catalog.sql;
@/u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/admin/catproc.sql;
@/u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/admin/catoctk.sql;
@/u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/admin/owminst.plb;
connect "SYSTEM"/"&&systemPassword"
@/u01/app/oracle/product/12.1.0.2/dbhome_1/sqlplus/admin/pupbld.sql;
connect "SYSTEM"/"&&systemPassword"
set echo on
spool /u01/app/oracle/admin/IMDB/scripts/sqlPlusHelp.log append
@/u01/app/oracle/product/12.1.0.2/dbhome_1/sqlplus/admin/help/hlpbld.sql helpus.sql;
spool off
spool off
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /u01/app/oracle/admin/IMDB/scripts/postDBCreation.log append
grant sysdg to sysdg;
grant sysbackup to sysbackup;
grant syskm to syskm;
