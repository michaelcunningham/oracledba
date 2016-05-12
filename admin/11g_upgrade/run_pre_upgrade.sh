#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID> [home1 | home2]"
  echo
  echo "        Example : $0 novadev home2"
  echo
  exit
else
  export ORACLE_SID=$1
  export which_home=$2
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

if [ "$which_home" = "home1" ]
then
  . /dba/admin/11g_upgrade/set_upgrade_env_home1.sh $ORACLE_SID
else
  . /dba/admin/11g_upgrade/set_upgrade_env_home2.sh $ORACLE_SID
fi

sqlplus -s /nolog << EOF
connect / as sysdba
@?/rdbms/admin/utlrp.sql
purge dba_recyclebin;

begin
	dbms_stats.gather_dictionary_stats;
end;
/

spool /oracle/app/oracle/admin/$ORACLE_SID/adhoc/upgrade_info.log
@$ORACLE_HOME_11g/rdbms/admin/utlu112i.sql
spool off
exit;
EOF
