drop table verify_consolidate
/
create table verify_consolidate
( db_name varchar2(20),
  object_name varchar2(80),
  object_type varchar2(20),
  seq_last_number number(38)
) tablespace datatbs1
/
