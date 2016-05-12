merge into verify_consolidate v
using ( select sequence_name,last_number from user_sequences@NEW_TDB01 ) u
on (v.object_name = u.sequence_name
     and v.object_type='SEQUENCE')
when matched then
update set v.seq_last_number = u.last_number
/
