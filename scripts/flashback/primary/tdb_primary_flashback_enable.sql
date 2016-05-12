set time on timing on echo on
set feedback on
set verify on
set heading on
set serveroutput on

alter system set db_recovery_file_dest_size=35G SCOPE=both
/
alter system set db_recovery_file_dest='+FRA' SCOPE=both
/
alter database flashback on
/

create pfile from spfile
/
