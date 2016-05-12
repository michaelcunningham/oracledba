alter session set events '10046 trace name context forever, level 12';

create table tt2
as
select * from dba_objects;

create index tt2_ie2 on tt2( object_name, owner );

exec dbms_stats.gather_table_stats( user, 'TT2', cascade => true );

alter session set events '10046 trace name context off';
