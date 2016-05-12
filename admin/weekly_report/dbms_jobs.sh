#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <tns>"
  echo
  echo "        Example : $0 novadev"
  echo
  exit
fi

export tns=$1
username=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

sysuser=sys
sysuserpwd=`get_sys_pwd $tns`

sqlplus -s /nolog << EOF
connect $sysuser/$sysuserpwd@$tns as sysdba

set serveroutput on
set feedback off
set tab off

column job          format 99999   heading 'Job'
column schema_user  format a16     heading 'Schema User'
column last_date    format a20     heading 'Last Date'
column next_date    format a20     heading 'Next Date'
column broken       format a6      heading 'Broken'

alter session set nls_date_format='DD-MON-YYYY HH24:MI';

begin
	dbms_output.put_line( upper( sys_context( 'USERENV', 'INSTANCE_NAME' ) ) || ' Jobs' );
end;
/

select job, schema_user, last_date, next_date, broken from dba_jobs;

exit;
EOF

