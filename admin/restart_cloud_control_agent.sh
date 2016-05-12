#!/bin/sh

HOST=`hostname -s`

log_dir=/mnt/dba/logs/$HOST
log_file=${log_dir}/restart_cloud_control_agent.log
email_body_file=${log_dir}/restart_cloud_control_agent.email
mkdir -p $log_dir

EMAILDBA=dba@tagged.com

result=`sudo cat /proc/sys/fs/aio-nr`
if [ $result -lt 1000000 ]
then
  # If the value of /proc/sys/fs/aio-nr is less than 1,000,000 just exit
  exit
fi


if [ -f "/etc/rc.d/init.d/gcstartup" ]
then
  echo "Restarting the Cloud Control Agent" > $log_file
  echo "" >> $log_file
  echo "Before value of /proc/sys/fs/aio-nr is: "$result >> $log_file
  echo "" >> $log_file

  result=`ps x | grep gcagent_core | grep -v grep`
  if [ -n "$result" ]
  then
    sudo /etc/rc.d/init.d/gcstartup stop >> $log_file
    echo "" >> $log_file
  fi

  sudo /etc/rc.d/init.d/gcstartup start >> $log_file
  echo "" >> $log_file
  result=`sudo cat /proc/sys/fs/aio-nr`
  echo "" >> $log_file
  echo "After value of /proc/sys/fs/aio-nr is: "$result >> $log_file

  result=`ps x | grep gcagent_core | grep -v grep`
  if [ -z "$result" ]
  then
    echo "The cloud agent failed to restart while restarting the cloud agent on $HOST" > $email_body_file
    echo "The log file contains the following" >> $email_body_file
    echo "" >> $email_body_file
    cat $log_file >> $email_body_file
    echo "" >> $email_body_file
    echo "################################################################################" >> $email_body_file
    echo "" >> $email_body_file
    echo 'This report created by : '$0 $* >> $email_body_file
    echo "" >> $email_body_file
    echo "################################################################################" >> $email_body_file
    echo "" >> $email_body_file
    mail -s "WARNING: $HOST - Cloud Agent did not restart" $EMAILDBA < $email_body_file
  fi
fi

