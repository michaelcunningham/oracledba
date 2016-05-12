set linesize 260
set pagesize 100
column name format a20
column eta format a20

column name		format a20
column pct_done		format 990.00
column est_hours	format 990.00
column group_number	format 00
column operation	format a9
column pass		format a9
column state		format a5
--column power
--column actual
column sofar		format 999,999,999
column est_work		format 999,999,999,999
--column est_rate
--column est_minutes
--column error_code
--column con_id
column mb_sec		format 999,999,999

select	d.name, round( ( sofar/decode( est_work,0,1,est_work ) )*100,2 ) pct_done,
	round( o.est_minutes/60,2 ) est_hours, o.pass, o.state,
	--round( o.est_minutes/60,2 ) est_hours, o.state,
	o.sofar, o.est_work, round( est_rate/60,2 ) mb_sec,
	to_char( sysdate + ( est_minutes/60/24 ), 'YYYY-MM-DD hh24:mi:ss' ) eta
from	v$asm_operation o, v$asm_diskgroup d
where	o.group_number = d.group_number (+)
order by d.name, o.pass desc;
