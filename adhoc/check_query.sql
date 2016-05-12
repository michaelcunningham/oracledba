set serveroutput off
set autotrace off
set linesize 150
set pagesize 100
set serveroutput off
set linesize 150
set pagesize 100
set autotrace off
variable n_thread_id number;
variable n_user_id number;
variable n_rows number;

exec :n_user_id := 7280151987;

set autotrace on explain statistics

--alter session set events '10046 trace name context forever, level 12';

SELECT count(*) 
FROM tag.MESSAGES m 
INNER JOIN tag.MESSAGES_STATUS ms ON m.thread_id = ms.thread_id 
WHERE ms.user_id = :n_user_id
AND m.EVENT_TS BETWEEN 1450020482000 - 86400000 and 1461020482000
/
