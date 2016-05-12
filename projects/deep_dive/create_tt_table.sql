create table tt
as
select * from dba_objects;

create unique index tt_pk on tt( object_id );

create index tt_ie2 on tt( object_name, owner );

create index tt_ie1 on tt( object_name );
