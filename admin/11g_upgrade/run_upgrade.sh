#!/bin/sh

##############################################################################################################
#
# Before running this script the following must be done.
#
#  Verify the environment is setup for 11g
#
#	. /dba/admin/11g_upgrade/set_db_oratab_11g.sh $ORACLE_SID
#
#  Setup the password file
#
#	$ORACLE_HOME/bin/orapwd file=$ORACLE_HOME/dbs/orapw${ORACLE_SID} password=<pwd> force=y
#
#  Configure the network files
#
#	tnsnames.ora
#	listener.ora
#
#  Configure init.ora file like normal TDC method.
#
#	ln -s $ORACLE_ADMIN/${ORACLE_SID}/pfile/init${ORACLE_SID}.ora $ORACLE_HOME/dbs/init${ORACLE_SID}.ora
#
##############################################################################################################

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

cd $ORACLE_HOME/rdbms/admin

sqlplus -s /nolog << EOF
connect / as sysdba
create spfile from pfile='$pfile_11g';
startup upgrade
spool /oracle/app/oracle/admin/$ORACLE_SID/adhoc/upgrade.log
@catupgrd.sql
spool off
exit;
EOF
