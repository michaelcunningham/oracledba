--
-- select hash_value from v$sql where sql_id = '2yhyu5brg860s';
-- 4008974360
--

--alter session set tracefile_identifier='s4_bad_580_10046_10053_trace_run_1';
--alter system set events 'immediate trace name cursortrace level 580, address 3052100244';
--alter session set events '10053 trace name context forever, level 1';
--alter session set events '10046 trace name context forever, level 12';

variable s_object_name varchar2(32);
exec :s_object_name := 'DBMS_TRACE_LIB';

select	object_id, owner, object_name, object_type
from	tt_no_exist
where	object_name = :s_object_name;

--alter session set events '10053 trace name context off';
--alter session set events '10046 trace name context off';
--alter system set events 'immediate trace name cursortrace level 2147483648, address 1';
