#!/bin/sh

EMAILDBA=dba@ifwe.co
#EMAILDBA=falramahi@ifwe.co
HOST=`hostname -s`
alertlog_test="ORA-|^ERROR:|WARNING: Read Failed|OS Error|failed"
alert_exclude="ORA-12151|ORA-00060|ORA-3136|ORA-609|ORA-00001|kewrsp_split_partition|ORA-19815"
sid_list=`cat /etc/oratab | grep -v \^$ | grep -v \^# | grep -v \* | egrep -v "ASM|MGMTDB" | cut -d: -f1`
##sid_list='TDB33'
##if [ "$1" = "" ]
##then
##  echo
##  echo "	Usage: $0 <ORACLE_SID> [alertlog test string] default=$alertlog_test"
##  echo
##  echo "	Example: $0 orcl \"ORA-|^ERROR:\""
##  echo
##  echo "	Optional: Separate the errors by | to check for multiple."
##  echo
##  exit 1
##fi

if [ "$2" != "" ]
then
  alertlog_test=$2
fi 

for sid in $sid_list
do
 export ORACLE_SID=$sid

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

admin_dir=/mnt/dba/admin
#alert_log_dir=/mnt/dba/logs/$ORACLE_SID

#
# Check to make sure the user actually exists
#
bdump_dir=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
--select value from v\\$parameter where name = 'background_dump_dest';
select value from v\\$diag_info where name = 'Diag Trace';
exit;
EOF`

bdump_dir=`echo $bdump_dir`

if [ "$bdump_dir" = "" ]
then
  echo
  echo "	Cannot determine the bdump directory for this database."
  echo
  exit
fi

db_unique_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select db_unique_name from v\\$database;
exit;
EOF`
db_unique_name=`echo $db_unique_name`

today=`date +"%Y%m%d"`
alert_log_dir=/mnt/dba/logs/$ORACLE_SID
alert_log_filename=$bdump_dir/alert_${ORACLE_SID}.log
alert_log_old=$bdump_dir/alert_${ORACLE_SID}.log.${today}
alert_log_current_filename=$alert_log_dir/alert_${db_unique_name}_current.log
alert_log_prior_filename=$alert_log_dir/alert_${db_unique_name}_prior.log
alert_log_diff_filename=$alert_log_dir/alert_${db_unique_name}_diff.log
mail_message=$alert_log_dir/email_${db_unique_name}.email
mkdir -p $alert_log_dir


# Test section for variables
# echo "bdump_dir                  = "$bdump_dir
# echo "alert_log_filename         = "$alert_log_filename
# echo "alert_log_current_filename = "$alert_log_current_filename
# echo "alert_log_prior_filename   = "$alert_log_prior_filename
# echo "alert_log_diff_filename    = "$alert_log_diff_filename

if [ ! -s $alert_log_prior_filename ]
then
	# The PRIOR alert log has never been created so let's create it now.
	# The next time this script runs it will be able to do a diff since
	# the files should be different at that time.
	cp $alert_log_filename $alert_log_prior_filename
fi

cp $alert_log_filename $alert_log_current_filename
#sleep 20
diff $alert_log_current_filename $alert_log_prior_filename > $alert_log_diff_filename

error_detected=`egrep -a -i "${alertlog_test}" ${alert_log_diff_filename} | egrep -v ${alert_exclude}`

if [ "$error_detected" != "" ]
then
	# We have found a line in the alert log matching the $alertlog_test value
	# so let's send an email so someone can look at it.
	email_subj="WARNING: errors found in alert log for $ORACLE_SID"
	echo "Errors have been found in the ASM alert log matching the following string." > $mail_message
	echo "	$alertlog_test" >> $mail_message
	echo "" >> $mail_message
	echo "Alert log file = $alert_log_filename" >> $mail_message
	echo "The attached file shows the new errors in the alert log." >> $mail_message
	echo "" >> $mail_message
	echo "" >> $mail_message
	echo "######################################################################" >> $mail_message
	echo "" >> $mail_message
	echo 'This report created by : '$0' '$* >> $mail_message
	echo "" >> $mail_message
	echo "######################################################################" >> $mail_message
	echo "" >> $mail_message

	# mail -s "$email_subj" $EMAILDBA < $mail_message
	#echo "$mail_message" | mailx -s "$email_subj" -a $alert_log_diff_filename $EMAILDBA 
	echo $error_detected | mailx -s "$email_subj" $EMAILDBA
fi

cp $alert_log_current_filename $alert_log_prior_filename
done

find ${bdump_dir} -iname alert_${ORACLE_SID}.log -size +5M -exec mv {} ${alert_log_old} \;
touch $alert_log_filename

