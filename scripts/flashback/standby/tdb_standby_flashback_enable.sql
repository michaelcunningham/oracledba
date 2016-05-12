set time on timing on echo on
set feedback on
set verify on
set heading on
set serveroutput on

alter database recover managed standby database cancel
/

alter database flashback off
/

alter system set db_recovery_file_dest_size=30G SCOPE=both
/
--alter system set db_recovery_file_dest='+FRA' SCOPE=both
--/
alter database flashback on
/
alter database recover managed standby database disconnect
/
create pfile from spfile
/
