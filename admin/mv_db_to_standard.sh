#!/bin/sh

##########################################################################################
#
# Before running this script do the following.
#
# Verify the tnsnames.ora and listener.ora have been configured in the new ORACLE_HOME.
#
# export OLD_ORACLE_HOME=/oracle/app/oracle/product/10.2.0/db_1
# export NEW_ORACLE_HOME=/oracle/app/oracle/product/10.2.0/db_2
#
# For the first database ONLY that is being moved on this server do the following.
# Once this is done the first time it does not need to be done again.
#
# cp ${OLD_ORACLE_HOME}/network/admin/listener.ora ${NEW_ORACLE_HOME}/network/admin
# cp ${OLD_ORACLE_HOME}/network/admin/tnsnames.ora ${NEW_ORACLE_HOME}/network/admin
# sed -i "s/db_1/db_2/g" ${NEW_ORACLE_HOME}/network/admin/tnsnames.ora
# sed -i "s/db_1/db_2/g" ${NEW_ORACLE_HOME}/network/admin/listener.ora
#
##########################################################################################

#
# BEFORE PROCEEDING SHUTDOWN THE DATABASE.
#

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

cp ${OLD_ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora ${NEW_ORACLE_HOME}/dbs
cp ${OLD_ORACLE_HOME}/dbs/orapw${ORACLE_SID} ${NEW_ORACLE_HOME}/dbs

ln -s -f /oracle/app/oracle/admin/${ORACLE_SID}/pfile/init${ORACLE_SID}.ora $NEW_ORACLE_HOME/dbs/init${ORACLE_SID}.ora

echo
echo "	Modify the /etc/oratab file to point to the new ORACLE_HOME."
echo "	Then close all xterm sessions and reopen before proceeding. "
echo " "

exit 0

