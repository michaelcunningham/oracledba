#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_template_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_template_${log_date}.email
mkdir -p $log_dir

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

EMAILDBA=dba@tagged.com

####################################################################################################
#
# Start code below here
#
# The idea behind the log_file in the example is that if the log_file has anything in it then an
# email will be sent about the status.
# It is expexted that a successful execution will leave an empty log_file.
#
####################################################################################################

sqlplus -s / as sysdba << EOF > $log_file
set serveroutput on
set linesize 200
set feedback off

declare
	s_sql			varchar2(500);
	s_dummy			varchar2(500);
	b_exception		boolean;
	s_exception_text	varchar(500);
begin
	s_sql := 'select dummy from dual';

	begin
		execute immediate s_sql into s_dummy;
	exception
		when others then
			b_exception := true;
			s_exception_text := 'Error Code ORA' || SQLCODE;
			dbms_output.put_line( s_exception_text );
	end;
end;
/

exit;
EOF

if [ -s $log_file ]
then
	echo "List of invalid database links in the "$ORACLE_SID" database." > $email_body_file
	echo "" >> $email_body_file
	cat $log_file >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file
	echo 'This report created by : '$0 >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file

	mail_subj=`echo $ORACLE_SID | awk '{print toupper($0)}'`" - Invalid Objects"
	mail -s "${ORACLE_SID} DB Link report" mcunningham@tagged.com < $email_body_file
fi
