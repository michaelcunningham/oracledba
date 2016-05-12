#!/bin/sh

#sqlplus tag/zx6j1bft@stage1 << EOF
#truncate table verify_consolidate;
#EOF

for i in `seq 00 15`
do
printf -v ORACLE_SID 'TDB%02d' $i
echo $ORACLE_SID
sqlplus tag/zx6j1bft@stage1 << EOF

insert into verify_consolidate(db_name,object_name,object_type) select '$ORACLE_SID',object_name,object_type from 
user_objects@$ORACLE_SID; 

commit;
exit
EOF
done

for i in `seq 00 15`
do
printf -v ORACLE_SID 'TDB%02d' $i
echo $ORACLE_SID
sqlplus tag/zx6j1bft@stage1 << EOF

merge into verify_consolidate v
using ( select sequence_name,last_number from user_sequences@$ORACLE_SID ) u
on (v.object_name = u.sequence_name
     and v.object_type='SEQUENCE')
when matched then
update set v.seq_last_number = u.last_number;

commit;
exit
EOF
done


for i in `seq 01 02`
do
printf -v ORACLE_SID 'TDB%02d' $i
printf -v ORACLE_SID `echo NEW_$ORACLE_SID`
echo $ORACLE_SID
sqlplus tag/zx6j1bft@stage1 << EOF

insert into verify_consolidate(db_name,object_name,object_type) select '$ORACLE_SID',object_name,object_type from
user_objects@$ORACLE_SID;

commit;
exit
EOF
done

for i in `seq 01 02`
do
printf -v ORACLE_SID 'TDB%02d' $i
printf -v ORACLE_SID `echo NEW_$ORACLE_SID`
echo $ORACLE_SID
sqlplus tag/zx6j1bft@stage1 << EOF

merge into verify_consolidate v
using ( select sequence_name,last_number from user_sequences@$ORACLE_SID ) u
on (v.object_name = u.sequence_name
     and v.object_type='SEQUENCE')
when matched then
update set v.seq_last_number = u.last_number;

commit;
exit
EOF
done

