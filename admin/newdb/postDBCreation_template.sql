SET VERIFY OFF
spool /u01/app/oracle/admin/db_name_template/scripts/postDBCreation.log append
@/u01/app/oracle/product/12.1.0/dbhome_1/rdbms/admin/catbundle.sql psu apply;
shutdown immediate;
connect "SYS"/"&&sysPassword" as SYSDBA
startup mount pfile="/u01/app/oracle/admin/db_name_template/scripts/init.ora";
alter database archivelog;
alter database open;
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
create spfile from pfile='/u01/app/oracle/admin/db_name_template/scripts/init.ora';

connect "SYS"/"&&sysPassword" as SYSDBA
select 'utlrp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
@/u01/app/oracle/product/12.1.0/dbhome_1/rdbms/admin/utlrp.sql;
select 'utlrp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
select comp_id, status from dba_registry;
shutdown immediate;
host /u01/app/oracle/product/12.1.0/dbhome_1/bin/srvctl enable database -db db_name_templatea;
host /u01/app/oracle/product/12.1.0/dbhome_1/bin/srvctl start database -db db_name_templatea;
connect "SYS"/"&&sysPassword" as SYSDBA

-- This is just for databases on Virtual Machines to help with performance.
-- Turn off vktm (Virtual Keeper of Time)
alter system set "_high_priority_processes"='' scope=spfile;

create pfile from spfile;
spool off
exit;
