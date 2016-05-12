--alter session set tracefile_identifier='s4_10053_10046_trace_run_2';
--alter session set events '10053 trace name context forever, level 1';
alter session set events '10046 trace name context forever, level 12';

variable s_object_name varchar2(32);
exec :s_object_name := 'DBMS_TRACE_LIB';

select	object_id, owner, object_name, object_type
from	tt
where	object_name = :s_object_name;

--alter session set events '10053 trace name context off';
alter session set events '10046 trace name context off';
