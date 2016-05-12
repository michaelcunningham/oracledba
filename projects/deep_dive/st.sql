connect michael/michael
select /* TT_TEST */ distinct object_type from tt where object_name like 'SY%';
disconnect
exit

connect michael/michael
--alter session set sql_trace=true;
--alter session set events '10270 trace name context forever, level 15';
select /* TT_TEST */ distinct object_type from tt where object_name like 'SY%';
--alter session set events '10270 trace name context off';
disconnect
exit
