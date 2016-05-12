#!/bin/ksh

instance_list=`cat /etc/oratab | grep Y$ | cut -f1 -d: | grep -v tdc247 | grep -v stprd2 | grep -v dwqa`

for this_instance in $instance_list
do
  # echo $this_instance
  /dba/admin/chk_db_status.sh $this_instance
  result=$?
  if [ "$result" = "1" ]
  then
    # send email that the instance is down
    # echo "instance is down"
    dp 5/DB FAULT - $this_instance instance is down
    dp 2/DB FAULT - $this_instance instance is down
    dp 7/DB FAULT - $this_instance instance is down
  elif [ "$result" = "2" ]
  then
    # send email that we cannot connect to the instance
    # echo "cannot connect"
    dp 5/DB FAULT - $this_instance cannot connect
    dp 2/DB FAULT - $this_instance cannot connect
    dp 7/DB FAULT - $this_instance cannot connect
  fi
done
