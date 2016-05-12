create table profiler_test
as
with gen as(
	select	--+ materialize
		rownum id
	from	all_objects
	where	rownum <= 5000
)
select	rownum id,
	lpad(rownum,10,'0') val1,
	trunc(sqrt(rownum)) val2,
	lpad(trunc(sqrt(rownum)),4,'0') val3,
	rpad('x',150,'x')
		|| lpad(trunc(sqrt(rownum)),4,'0') || rpad('x',26,'x')
		|| lpad(rownum,10,'0') || rpad('x',10,'x') search
from	gen t1, gen t2
where	rownum <= 100000;
