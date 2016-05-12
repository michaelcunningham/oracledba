#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" -o "$4" = "" ]
then
  echo
  echo "   Usage: $0 <standby_db> <primary_db> <standby_sequence> <primary_sequence"
  echo
  echo "   Example: $0 dwphy1 dwprd 12345 12345"
  echo
  exit
fi

. /dba/admin/dba.lib

standby_name=$1        # varchar2(16)
primary_name=$2        # varchar2(16)
standby_sequence=$3    # integer
primary_sequence=$4    # integer

export ORACLE_SID=$standby_name
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=tdce
userpwd=tdce

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

--insert into db_standby_lag_status(
--	db_standby_lag_status_id,
--	standby_name, primary_name,
--	standby_sequence#, primary_sequence# )
--values(
--	db_standby_lag_status_seq.nextval,
--	'$standby_name', '$primary_name',
--	$standby_sequence, $primary_sequence );

merge into db_standby_lag_status t
using (
        select  '$standby_name' standby_name,
                '$primary_name' primary_name,
                '$standby_sequence' standby_sequence,
                '$primary_sequence' primary_sequence,
                sysdate last_updated
        from    dual ) s
on      ( t.standby_name = s.standby_name )
when matched then
        update
        set     standby_sequence# = '$standby_sequence',
                primary_sequence# = '$primary_sequence',
                last_updated = sysdate
when not matched then insert(
                standby_name, primary_name,
                standby_sequence#, primary_sequence#, last_updated )
        values( s.standby_name, s.primary_name,
                s.standby_sequence, s.primary_sequence, s.last_updated );
commit;

exit;
EOF
