set echo on
set time on timing on
create table messages_test NOLOGGING tablespace datatbs1 
as select * from messages@imtestora where message_id>38000000001 
and  message_id<40000000002
/
