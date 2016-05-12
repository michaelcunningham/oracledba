set verify off
set serveroutput on
--
ttitle on

clear breaks

alter session set nls_date_format='DD-MON-YYYY HH24:MI';

column oldest_flashback_scn      format 9999999999      heading 'Oldest SCN'
column oldest_flashback_time                            heading 'Oldest Time'
column retention_target                                 heading 'Ret Target'
column flashback_size            format 999,999,999,999 heading 'Flashback Size'
column estimated_flashback_size  format 999,999,999,999 heading 'Estimated Size'

column file_type                 format a20             heading 'File Type'
column percent_space_used        format 990.99          heading '% Used'
column percent_space_reclaimable format 990.99          heading '% Reclaimable'
column number_of_files           format 999,999,999,999 heading '# of Files'

set linesize 76
ttitle center '*****  Flashback Database Log  *****' skip 2

select	oldest_flashback_scn, oldest_flashback_time, retention_target,
	flashback_size, estimated_flashback_size
from	v$flashback_database_log;

set linesize 62
ttitle center '*****  Flashback Area Usage  *****' skip 2

select	file_type, percent_space_used, percent_space_reclaimable,
	number_of_files
from	v$flash_recovery_area_usage;

