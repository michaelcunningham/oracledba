#!/bin/sh

SID_LIST=$(for i in {0..15}; do printf 'TDB%02d ' $i; done);

for i in `seq 00 15`
do
printf -v ORACLE_SID 'TDB%02d' $i
echo $ORACLE_SID
export ORACLE_SID
sqlplus "/ as sysdba" << EOF
set pages 0
set feedback off
select object_type,count(*) from dba_objects group by object_type;
exit
EOF
done
