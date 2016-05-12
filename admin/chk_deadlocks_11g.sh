#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage: $0 <trace_file>"
  echo
  echo "        Example: $0 tdcqa2_ora_8922.trc"
  echo
  exit 2
else
  export trace_file=$1
fi

log_file=/mnt/dba/logs/deadlock.log

>$log_file
echo "There may be several tables involved in a deadlock and this file will contain" >> $log_file
echo "all of the tables." >> $log_file
echo >> $log_file

echo $trace_file

what_time=`grep "^\*\*\*" $trace_file | head -1 |  awk '{print $3}' | cut -f1,2,3 -d":"`

lock_type=`grep "Resource Name" $trace_file -A3 | head -2 | tail -1 | cut -d- -f1`
if [ "$lock_type" = "TX" ]
then
  lock_type="TX - row lock contention"
fi

session_id_1=`grep "^session " $trace_file | head -1 | cut -d: -f1 | awk '{print $2}'`
session_id_2=`grep "^session " $trace_file | tail -1 | cut -d: -f1 | awk '{print $2}'`

lock_obj_1=`grep "Rows waited on" $trace_file -A5 | grep "Session $session_id_1" -A1 | tail -1 | awk '{print $4}' | sed "s/,//"`
lock_obj_2=`grep "Rows waited on" $trace_file -A5 | grep "Session $session_id_2" -A1 | tail -1 | awk '{print $4}' | sed "s/,//"`

lock_obj_hex_1=`grep "Rows waited on" $trace_file -A5 | grep "Session $session_id_1" | cut -d- -f2 | awk '{print $3}'`
lock_obj_hex_2=`grep "Rows waited on" $trace_file -A5 | grep "Session $session_id_2" | cut -d- -f2 | awk '{print $3}'`

this_statement=`grep "Current SQL Statement for this session" $trace_file -A1 -m1 | tail -1`
that_statement=`grep "current SQL" $trace_file -A1 -m1 | tail -1`

echo "what_time         "$what_time
echo "lock_type         "$lock_type
echo "session_id_1      "$session_id_1
echo "session_id_2      "$session_id_2
echo "lock_obj_1        "$lock_obj_1
echo "lock_obj_2        "$lock_obj_2
echo "lock_obj_hex_1    "$lock_obj_hex_1
echo "lock_obj_hex_2    "$lock_obj_hex_2

echo "The deadlock information in this file happened at:  "$what_time  >> $log_file
echo "The lock type experienced was:                      "$lock_type"."  >> $log_file
echo "The session ID's involved are:                      "$session_id_1" & "$session_id_2"."  >> $log_file
echo "The locked object numbers involved are:             "$lock_obj_1" & "$lock_obj_2"."  >> $log_file
echo >> $log_file

echo "----- Statement was being executed by session id "$session_id_1"-----."  >> $log_file
echo $this_statement  >> $log_file
echo >> $log_file

echo "----- Statement was being executed by session id "$session_id_2"-----."  >> $log_file
echo $that_statement  >> $log_file
#echo >> $log_file

sqlplus -s /nolog << EOF >> $log_file
connect / as sysdba
@/mnt/dba/scripts/chk_deadlock_obj.sql $lock_obj_hex_1
@/mnt/dba/scripts/chk_deadlock_obj.sql $lock_obj_hex_2
exit;
EOF

#grep ^TM $trace_file | cut -f2 -d- | sort | uniq | while read objhex
#do
#sqlplus -s /nolog << EOF >> $log_file
#connect / as sysdba
#@/dba/scripts/chk_deadlock_obj.sql $objhex
#exit;
#EOF
#done

mail -s "Deadlock Information" mcunningham@ifwe.co < $log_file
