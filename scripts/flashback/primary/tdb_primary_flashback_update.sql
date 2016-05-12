set time on timing on echo on
set feedback on
set verify on
set heading on
set serveroutput on

alter system set  db_flashback_retention_target=1080  SCOPE=both
/

create pfile from spfile
/
