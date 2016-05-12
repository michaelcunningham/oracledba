set linesize 140
set pagesize 1000          
 
set trimspool on         
 
break on timed_at skip 1          
 
column timed_at  format a18
column oper_type format a12
column component format a24
column parameter format a21          
column oper_mode format a10

select	to_char(start_time,'dd_Mon-yy hh24:mi:ss') timed_at, oper_type, component,
	parameter, oper_mode, initial_size,
	final_size, abs( final_size - initial_size ) size_change
from	v$sga_resize_ops
order by start_time, component;          
