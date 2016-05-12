#!/bin/sh

. /dba/admin/dba.lib

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <primary db tns> <standby db tns> [archive lag threshold]"
  echo
  echo "   Example: $0 dwprd dwprd 10"
  echo
  exit
fi

if [ "$3" = "" ]
then
  archive_lag_threshold=10
else
  archive_lag_threshold=$3
fi

PRIMARY_TNS=$1
STANDBY_TNS=$2

PRIMARY_USER=sys
PRIMARY_PASS=`get_sys_pwd $PRIMARY_TNS`
STANDBY_ORACLE_SID=`get_orasid_from_tns $STANDBY_TNS`
STANDBY_USER=sys
STANDBY_PASS=`get_sys_pwd $STANDBY_TNS`

echo $STANDBY_ORACLE_SID

export ORACLE_SID=$STANDBY_ORACLE_SID
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

#
# Here is where a test using tnsping should be used to
# make sure both databases can be reached.
#
tns_test=`$ORACLE_HOME/bin/tnsping $PRIMARY_TNS | grep OK | awk '{print $1}'`
if [ "$tns_test" != "OK" ]
then
  echo Cannot tnsping $PRIMARY_TNS
  exit
fi

admin_log_dir=/dba/admin/log
primary_lag_file=$admin_log_dir/${PRIMARY_TNS}_primary_lag.lst
standby_lag_file=$admin_log_dir/${STANDBY_TNS}_standby_lag.lst

rm $primary_lag_file
rm $standby_lag_file

export ORACLE_SID=$STANDBY_ORACLE_SID

sqlplus -s /nolog << EOF
connect / as sysdba
set feedback off
set heading off
spool ${standby_lag_file}
select max( sequence# ) from v\$log_history where resetlogs_change# = ( select resetlogs_change# from v\$database );
spool off
exit;
EOF

standby_test_prod=`cat ${standby_lag_file}`
#echo $standby_test_prod

sqlplus -s /nolog << EOF
connect $PRIMARY_USER/$PRIMARY_PASS@$PRIMARY_TNS as sysdba
set feedback off
set heading off
spool ${primary_lag_file}
select max( sequence# ) from v\$log_history where resetlogs_change# = ( select resetlogs_change# from v\$database );
spool off
exit;
EOF

primary_test_prod=`cat ${primary_lag_file}`
#echo $primary_test_prod

archive_lag=`expr $primary_test_prod - $standby_test_prod`
#echo "archive_lag "$archive_lag

# if [ $archive_lag -ge $archive_lag_threshold ]
# then
#   NODE=`uname -n`
#   dp 4/ERROR: $NODE Standby DB \(${ORACLE_SID}\) is behind by $archive_lag log files.
#   dp 3/ERROR: $NODE Standby DB \(${ORACLE_SID}\) is behind by $archive_lag log files.
#   dp 6/ERROR: $NODE Standby DB \(${ORACLE_SID}\) is behind by $archive_lag log files.
# fi

# /dba/admin/log_standby_lag_status.sh $STANDBY_ORACLE_SID $PRIMARY_TNS $standby_test_prod $primary_test_prod
