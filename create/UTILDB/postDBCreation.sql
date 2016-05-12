SET VERIFY OFF
spool /u01/app/oracle/admin/IMDB/scripts/postDBCreation.log append
@/u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/admin/catbundleapply.sql;
shutdown immediate;
connect "SYS"/"&&sysPassword" as SYSDBA
startup mount pfile="/u01/app/oracle/admin/IMDB/scripts/init.ora";
alter database archivelog;
alter database open;
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
create spfile='+IMDBDATA' FROM pfile='/u01/app/oracle/admin/IMDB/scripts/init.ora';
connect "SYS"/"&&sysPassword" as SYSDBA
select 'utlrp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
@/u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/admin/utlrp.sql;
select 'utlrp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
select comp_id, status from dba_registry;
shutdown immediate;
host /u01/app/oracle/product/12.1.0.2/dbhome_1/bin/srvctl enable database -d IMDB;
host /u01/app/oracle/product/12.1.0.2/dbhome_1/bin/srvctl start database -d IMDB;
connect "SYS"/"&&sysPassword" as SYSDBA
spool off
exit;
