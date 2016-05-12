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

log_file=/dba/scripts/deadlock.log

>$log_file
echo "There may be several tables involved in a deadlock and this file will contain" >> $log_file
echo "all of the tables." >> $log_file
echo >> $log_file

echo $trace_file

#what_time=`grep "^\*\*\*" $trace_file | head -1 | cut -f2,3 -d" "`
#what_time=`grep "^\*\*\*" $trace_file | head -1 | cut -f2,3,4,5 -d":" | cut -f2,3 -d" "`
what_time=`grep "^\*\*\*" $trace_file | head -1 |  awk '{print $3}' | cut -f1,2,3 -d":"`
echo "The deadlock information in this file happened at: "$what_time  >> $log_file
echo >> $log_file

grep ^TM $trace_file | cut -f2 -d- | sort | uniq | while read objhex
do
sqlplus -s /nolog << EOF >> $log_file
connect / as sysdba
@/dba/scripts/chk_deadlock_obj.sql $objhex
exit;
EOF
done

mail -s "Deadlock Information" mcunningham@thedoctors.com < $log_file
mail -s "Deadlock Information" swahby@thedoctors.com < $log_file
mail -s "Deadlock Information" jmitchell@thedoctors.com < $log_file
