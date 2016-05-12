#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <tablespace_name>"
  echo
  echo "   Example: $0 orcl DATATBS1"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export tablespace_name=$2
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_add_datafile_to_tablespace.log
email_body_file=${log_dir}/${ORACLE_SID}_add_datafile_to_tablespace.email
EMAILDBA=dba@tagged.com
PAGEDBA=dbaoncall@tagged.com

#
# Add a datafile to the tablespace_name
#

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba
set feedback off
set linesize 100
set serveroutput on

declare
	s_sql	varchar2(500);
begin
	select	'alter tablespace ' || tablespace_name || ' add datafile ''' || myfile || ''' size 30721m' sql_text
	into	s_sql
	from	(
		select	substr( file_name, 1, ( instr( file_name, '/' ) )- 1 ) myfile, tablespace_name
		from	dba_data_files
		where	tablespace_name = upper( '$tablespace_name' )
		)
	where	rownum = 1;

	dbms_output.put_line( 'Executing following command in $ORACLE_SID' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( s_sql );
	dbms_output.put_line( '	' );
	execute immediate s_sql;
end;
/

exit;
EOF

#
# If there is a log file then there was either an error with the script
# or, at least, one tablespace that is beyond the threshold.
# Check to see if it was an error or if space needs to be added.
#
if [ -s $log_file ]
then
  cat $log_file | grep "ORA-" > /dev/null
  if [ $? -eq 0 ]
  then
    mail_subj="CRITICAL: Add datafile to tablespace failed."
  else
    mail_subj="NOTICE: Add datafile to tablespace $tablespace_name"
  fi
    echo "" > $email_body_file
    cat $log_file >> $email_body_file
    echo "" >> $email_body_file
    echo "################################################################################" >> $email_body_file
    echo "" >> $email_body_file
    echo 'This report created by : '$0 $* >> $email_body_file
    echo "" >> $email_body_file
    echo "################################################################################" >> $email_body_file
    echo "" >> $email_body_file

    mail -s "$mail_subj" $EMAILDBA < $email_body_file
fi

event_description=`grep ^alter $log_file | sed "s/'//g"`
/mnt/dba/admin/log_event.sh "ADD_DATA_FILE" "$event_description" "$0 $*" $ORACLE_SID $HOST SUCCESS
