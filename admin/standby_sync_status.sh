#!/bin/sh

if [ $# -lt 3 ]
then
   echo
   echo "	Usage: $0 <sid_name> <standby_tns_entry> <log_difference_threshold> [THRESHOLD_MINUTES_behind]"
   echo
   echo "	$0 TAGDBA TAGDBB 8 60"
   echo
   exit 1
fi

export PRIMARY=$1;
export STANDBY=$2;
export THRESHOLD=$3;
export THRESHOLD_MINUTES=$4
if [ "$THRESHOLD_MINUTES" = "" ]
then
  THRESHOLD_MINUTES=60
fi

####################################################################################################
#
# This script may run from dbmon04 or from the server where the database exists.
# First let's see if we find DBMON04 in the /etc/oratab.
# If not, then we will get the first non ASM entry in the /etc/oratab and set the environment.
#
# DBMON04:/u01/app/oracle/product/10.2:N
# Let's use that to set the environment.

result=`cat /etc/oratab | grep ^DBMON04 | cut -d: -f1`
if [ "$result" != "DBMON04" ]
then
  result=`cat /etc/oratab | grep . | grep -v "^#" | grep -v +ASM | cut -d: -f1 | head -1`
fi

export ORACLE_SID=$result

####################################################################################################

export HOST=$(hostname -s)
unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

export PAGEDBA=dbaoncall@tagged.com
export MSG=/tmp/${PRIMARY}_message
> $MSG

syspwd=admin123

#
# Make sure both databases can be reached.
#
tns_test=`$ORACLE_HOME/bin/tnsping $PRIMARY | grep OK | awk '{print $1}'`
if [ "$tns_test" != "OK" ]
then
  echo "Cannot tnsping "$PRIMARY >> $MSG
fi

tns_test=`$ORACLE_HOME/bin/tnsping $STANDBY | grep OK | awk '{print $1}'`
if [ "$tns_test" != "OK" ]
then
  echo "Cannot tnsping "$STANDBY >> $MSG
fi

#
# Check that we can connect to each database.
#
connect_text=`sqlplus -s /nolog  << EOF
set termout off
whenever sqlerror exit 1
connect sys/$syspwd@$PRIMARY as sysdba
select count(*) from dual;
exit;
EOF`

status=$?
if [ $status -ne 0 ]
then
  echo "Cannot connect to $PRIMARY database." >> $MSG
fi

connect_text=`sqlplus -s /nolog  << EOF
set termout off
whenever sqlerror exit 1
connect sys/$syspwd@$STANDBY as sysdba
select count(*) from dual;
exit;
EOF`

status=$?
if [ $status -ne 0 ]
then
  echo "Cannot connect to $STANDBY database." >> $MSG
fi

if [ ! -s $MSG ]
then
primary_seq_cnt=`sqlplus -s /nolog  << EOF
set heading off
set feedback off
set verify off
set echo off
connect sys/$syspwd@$PRIMARY as sysdba
select max( sequence# ) from v\\$log_history where resetlogs_change# = ( select resetlogs_change# from v\\$database );
exit;
EOF`

primary_seq_cnt=`echo $primary_seq_cnt`

standby_seq_cnt=`sqlplus -s /nolog  << EOF
set heading off
set feedback off
set verify off
set echo off
connect sys/$syspwd@$STANDBY as sysdba
select max( sequence# ) from v\\$log_history where resetlogs_change# = ( select resetlogs_change# from v\\$database );
exit;
EOF`

standby_seq_cnt=`echo $standby_seq_cnt`

archive_lag=$((primary_seq_cnt - standby_seq_cnt))

/mnt/dba/admin/log_to_graphite.sh tagged.TDB.standby.$ORACLE_SID $archive_lag

# echo "primary_seq_cnt   = "$primary_seq_cnt
# echo "standby_seq_cnt   = "$standby_seq_cnt
# echo "archive_lag       = "$archive_lag

if [ $archive_lag -ge $THRESHOLD ]
then
  echo "The $STANDBY standby database is $archive_lag archive log files behind the primary database $PRIMARY." >> $MSG
fi

#
# Now, let's check how far behind we are.  If it is above the THRESHOLD_MINUTES then print output.
#
sqlplus -s /nolog << EOF >> $MSG
set heading off
set feedback off
set verify off
set echo off
connect sys/$syspwd@$STANDBY as sysdba
set serveroutput on

declare
	s_value			interval day(2) to second(0);
	n_minutes_behind	integer;
	n_threshold_minutes	integer := $THRESHOLD_MINUTES;
	s_msg			varchar2(500);
begin
	select	value
	into	s_value
	from	v\$dataguard_stats
	where	name = 'apply lag';

	select	( extract( day from s_value ) * 1440 ) + ( extract( hour from s_value ) * 60 ) + ( extract( minute from s_value ) )
	into	n_minutes_behind
	from	dual;

	if n_minutes_behind > n_threshold_minutes then
		s_msg := 'The ' || sys_context( 'USERENV', 'DB_UNIQUE_NAME' ) || ' standby database is ' || n_minutes_behind || ' minutes behind the primary.';
		dbms_output.put_line( s_msg );
	end if;
end;
/

exit;
EOF

fi

if [ -s $MSG ]
then
	echo "" >> $MSG
	echo "" >> $MSG
	echo "################################################################################" >> $MSG
	echo "" >> $MSG
	echo 'This report created by : '$0 $* >> $MSG
	echo "" >> $MSG
	echo "################################################################################" >> $MSG
	echo "" >> $MSG

	mail_subj="WARNING: $STANDBY Standby Database"
	mail -s "$mail_subj" $PAGEDBA < $MSG
fi
