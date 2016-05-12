set pagesize 100
set linesize 120
ttitle -
  center  'Submitted DBMS Jobs' skip 2

col job  format 99999  heading 'job#'
col subu format a10  heading 'Submitter'     trunc
col lsd  format a5   heading 'Last|Ok|Date'
col lst  format a5   heading 'Last|Ok|Time'
col nrd  format a5   heading 'Next|Run|Date'
col nrt  format a5   heading 'Next|Run|Time'
col fail format 999  heading 'Errs'
col ok   format a2   heading 'Ok'


select
  job,
  log_user                   subu,
  what                       proc,
  to_char(last_date,'MM/DD') lsd,
  substr(last_sec,1,5)       lst,
  to_char(next_date,'MM/DD') nrd,
  substr(next_sec,1,5)       nrt,
  failures                   fail,
  decode(broken,'Y','N','Y') ok
from
  sys.dba_jobs;

