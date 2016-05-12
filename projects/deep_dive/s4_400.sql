alter session set tracefile_identifier='s4_400_trace_run_1';

alter system set events 'immediate trace name cursortrace level 400, address 4008974360';

variable s_object_name varchar2(32);
exec :s_object_name := 'DBMS_TRACE_LIB';

select	object_id, owner, object_name, object_type
from	tt
where	object_name = :s_object_name;

alter system set events 'immediate trace name cursortrace level 2147483648, address 1';
