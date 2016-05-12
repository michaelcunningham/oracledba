--alter session set tracefile_identifier='run_580_trace';
--alter session set events '10046 trace name context forever, level 1';
alter system set events 'immediate trace name cursortrace level 580, address 280287561';

variable s_cc_iso varchar2(32);
exec :s_cc_iso := 'MIKE';

select	ipfrom, ipto
from	tag.ip_ref
where	cc_iso = :s_cc_iso;

--alter session set events '10046 trace name context off';
alter system set events 'immediate trace name cursortrace level 2147483648, address 1';

