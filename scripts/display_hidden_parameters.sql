SET LINESIZE 2000
--set pagesize 100
--SET TRIM ON TRIMSPOOL ON
SET HEADING ON
column parameter  format A40
column description format A70
column session_value format A30
column instance_value format A30
PROMPT Connect as sys.  pname should be the parameter name starting with the underscore.
SELECT a.ksppinm as parameter, 
       a.ksppdesc as description, 
       b.ksppstvl as session_value, 
       c.ksppstvl as instance_value 
FROM x$ksppi a, x$ksppcv b, x$ksppsv c 
WHERE a.indx = b.indx AND a.indx = c.indx AND a.ksppinm LIKE '\&pname%' escape '\' ORDER BY 1;
