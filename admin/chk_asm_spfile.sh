#!/bin/sh

#
# This scripts checks to see if ASM is using an spfile.
# If not, send NOTICE email.
#

# grep "+ASM" /etc/oratab > /dev/null
ps x | grep -v grep | grep pmon_+ASM > /dev/null
if [ $? -ne 0 ]
then
  # ASM is not on this machine, just exit.
  exit 1
fi

unset SQLPATH
export ORACLE_SID=+ASM
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
email_body_file=${log_dir}/${HOST}_chk_asm_spfile.email
EMAILDBA=dba@tagged.com

spfile_used=`sqlplus -s /nolog << EOF
connect / as sysdba
set heading off
set feedback off
set verify off
set echo off
select count(*) from v\\$parameter where name = 'spfile' and value is null;
exit;
EOF`

spfile_used=`echo $spfile_used`

if [ "$spfile_used" = "1" ]
then
  echo "The ASM instance on $HOST is not using an spfile." > $email_body_file
  echo "" >> $email_body_file
  echo "" >> $email_body_file
  echo "############################################################" >> $email_body_file
  echo "" >> $email_body_file
  echo 'This report created by : '$0 $* >> $email_body_file
  echo "" >> $email_body_file
  echo "############################################################" >> $email_body_file
  echo "" >> $email_body_file

  mail_subj="NOTICE: ASM not using spfile on $HOST"
  mail -s "$mail_subj" $EMAILDBA < $email_body_file
fi

