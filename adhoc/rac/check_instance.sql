set lines 200
set pages 100
select instance_name,host_name,status from gv$instance;  
select name DATABASE,open_mode from v$database;
