alter session set tracefile_identifier='s4_100_trace_run_2';

alter system set events 'immediate trace name cursortrace level 100, address 4008974360';

variable s_object_name varchar2(32);
exec :s_object_name := 'DBMS_TRACE_LIB';

select	object_id, owner, object_name, object_type
from	tt
where	object_name = :s_object_name;

alter system set events 'immediate trace name cursortrace level 2147483648, address 1';