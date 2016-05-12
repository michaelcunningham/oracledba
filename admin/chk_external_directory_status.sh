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

. /mnt/dba/admin/dba.lib

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_chk_external_directory_status_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_chk_external_directory_status_${log_date}.email

systemuserpwd=`get_sys_pwd $ORACLE_SID`

# echo "ORACLE_SID      = "$ORACLE_SID
# echo "systemuserpwd   = "$systemuserpwd





open_mode=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select open_mode from v\\$database;
exit;
EOF`

open_mode=`echo $open_mode`

if [ "$open_mode" != "READ WRITE" ]
then
  # We only check external directories for primary databases.  This is probably a standby database.  Just exit.
  exit
fi

sqlplus -s / as sysdba << EOF > $log_file
set serveroutput on
set linesize 200
set feedback off

declare
	s_file_name		varchar2(50);
	f1			utl_file.file_type;
begin
	s_file_name := '*';

	for r in( select owner, directory_name, directory_path from dba_directories )
	loop
		begin
			f1 := utl_file.fopen ( r.directory_name, s_file_name, 'w' );
		--	dbms_output.put_line( 'GOOD ... ' || r.directory_name );
			utl_file.fremove ( r.directory_name, s_file_name );
		exception
			when others then
				dbms_output.put_line( rpad( r.owner || '.' || r.directory_name, 42 ) || r.directory_path );
			--	dbms_output.put_line( r.directory_name || ' ' || SQLCODE || ' ' || SQLERRM );
		end;

		utl_file.fclose( f1 );
	end loop;
end;
/

exit;
EOF

#echo '' >> $log_file
#echo '' >> $log_file
#echo 'This report created by : '$0' '$* >> $log_file

if [ -s $log_file ]
then
	echo "List of invalid external directories in the "$ORACLE_SID" database." > $email_body_file
	echo "Server Name = "$(hostname -s) >> $email_body_file
	echo "" >> $email_body_file
	echo "Directory Name                            Directory Path" >> $email_body_file
	echo "----------------------------------------  ------------------------------" >> $email_body_file
	cat $log_file >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file
	echo 'This report created by : '$0 >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file

	mail_subj=`echo $ORACLE_SID | awk '{print toupper($0)}'`" - Invalid Objects"
	mail -s "${ORACLE_SID} DB external directory report" dba@tagged.com < $email_body_file
fi

