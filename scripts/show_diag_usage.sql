set linesize 160
set pagesize 100

SELECT name,value
FROM v$parameter 
where name='control_management_pack_access'
/
