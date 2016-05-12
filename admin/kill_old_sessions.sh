#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "Usage: $0 <ORACLE_SID>"
  echo "Example: $0 tdcdw"
  echo
  exit
else
  export ORACLE_SID=$1
fi

#
# Make sure the ORACLE_SID is running on this server.
#
ora_test=`ps -ef | grep pmon_${ORACLE_SID} | grep -v "grep pmon_${ORACLE_SID}"`

if [ "$ora_test" = "" ]
then
  echo
  echo "The "${ORACLE_SID}" instance is not running on this server."
  echo
  exit
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

> kill_old_sessions_${ORACLE_SID}.sql

sqlplus -s /nolog << EOF
connect / as sysdba
set serveroutput on
set feedback off
spool kill_old_sessions_${ORACLE_SID}.sql
declare
	dt_6pm		date;
	n_6pm_seconds	integer;
	s_sql		varchar2(200);
begin
	-- If is is after 6pm then set dt_6pm = Now + 18 hours.
	if to_char( sysdate, 'HH24') >= 18 then
		dt_6pm := trunc( sysdate ) + numtodsinterval( 8, 'hour' );
	else
	-- If is is prior to 6pm then set dt_6pm = Yesterday at 6pm.
	-- Just trunc the current date and subtract 6 hours.
		dt_6pm := trunc( sysdate ) - numtodsinterval( 6, 'hour' );
	end if;
	n_6pm_seconds := to_number( sysdate - dt_6pm ) * 86400;
--
        for r in (
			select	s.sid, s.serial# serial
			from	v\$session s
			where	s.user# <> 0
			and	s.status = 'INACTIVE'
			and	s.last_call_et > n_6pm_seconds )
	loop
		s_sql := 'alter system disconnect session ''' || r.sid || ',' || r.serial || ''' immediate;';
                dbms_output.put_line( s_sql );
	end loop;
end;
/
spool off
@kill_old_sessions_${ORACLE_SID}.sql
exit;
EOF
