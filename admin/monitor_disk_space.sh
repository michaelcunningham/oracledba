#!/bin/sh

if [ "$3" = "" ]
then
  echo
  echo "   Usage: $0 path critial warning"
  echo
  echo "   Example: $0 /mnt/oralog2 3 2"
  echo
  exit
fi

unset SQLPATH
HOST=`hostname -s`
job_name=monitor_disk_space
log_date=`date +%a`
log_dir=/mnt/dba/logs/$HOST
log_file=${log_dir}_${job_name}_${HOST}_${log_date}.log
email_body_file=${log_dir}/${HOST}_${job_name}_${log_date}.email
mkdir -p $log_dir

EMAILDBA=falramahi@tagged.com

####################################################################################################
#
#
# It is expexted that a successful execution will leave an empty log_file.
#
####################################################################################################

to_monitor=$1
alert_critical=$2
alert_warning=$3
space_unit=`df -H  ${to_monitor} | grep -vE '^Filesystem'| awk '{ print $4 }' | tail -c 2`

if [ $space_unit = "T" ]
   then
    free_space=`df -H  $to_monitor | grep -vE '^Filesystem'| awk '{ print $4 }' | cut -d"T" -f1`
fi

if [ $free_space -le $2 ]
   then 
    echo "Critical ... Running out of space $to_monitor ${alert_critical}T on $(hostname) as on $(date)" > $log_file
    mail_subj="`echo $ORACLE_SID` | Critical ... Running out of space $to_monitor currently is ${free_space}T"
    email_dba="dbaoncall@ifwe.co"
 
elif [ $free_space -le $3 ]
  then
    echo "Warning ... Running out of space $to_monitor ${alert_warning}T on $(hostname) as on $(date)" > $log_file
    mail_subj="`echo $ORACLE_SID` | Warning ... Running out of space $to_monitor currently is ${free_space}T"
    email_dba="dba@ifwe.co"
fi

if [ -s $log_file ]
then
	echo "Monitoring space on "$ORACLE_SID" database." > $email_body_file
	echo "" >> $email_body_file
	cat $log_file >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file
	echo 'This report created by : '$0 >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file


##	mail_subj="`echo $ORACLE_SID` | Critical ... Running out of space $to_monitor"
	mail -s "$mail_subj" $email_dba < $email_body_file
fi
