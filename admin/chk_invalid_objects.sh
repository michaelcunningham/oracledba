#!/bin/sh

#export ORAENV_ASK=NO

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  exit
fi

export ORACLE_SID=$1
. /usr/local/bin/oraenv

. /dba/admin/dba.lib

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_file=${adhoc_dir}/log/${ORACLE_SID}_chk_invalid_objects_${log_date}.txt
email_body_file=${adhoc_dir}/log/${ORACLE_SID}_chk_invalid_objects_${log_date}.email

sqlplus -s "/ as sysdba" << EOF > $log_file
set serveroutput on
set tab off
set linesize 200
set pagesize 200
set term off
set feedback off

column owner           format             a30 heading 'Owner'
column object_type     format             a30 heading 'Object Type'
column object_name     format             a30 heading 'Object Name'

select owner, object_type, object_name
from   dba_objects
where  status <> 'VALID'
order by 1,2,3;

exit;
EOF

#echo '' >> $log_file
#echo '' >> $log_file
#echo 'This report created by : '$0' '$* >> $log_file

if [ -s $log_file ]
then
	echo "The attached file includes a list of invalid objects." > $email_body_file
	echo "" >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file
	echo 'This report created by : '$0 >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file

#	email_group="cangelov@thedoctors.com, llangelan@thedoctors.com, cmusgrave@thedoctors.com, bsathyan@thedoctors.com, rteotia@thedoctors.com"
	mail_subj=`echo $ORACLE_SID | awk '{print toupper($0)}'`" - Invalid Objects"
	mutt -s "$mail_subj" mcunningham@thedoctors.com -a $log_file < $email_body_file
fi

