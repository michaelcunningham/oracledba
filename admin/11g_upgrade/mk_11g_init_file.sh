#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 novadev"
  echo
  exit
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/11g_upgrade/set_upgrade_env.sh $ORACLE_SID

#pfile_10g=$ORACLE_ADMIN/${ORACLE_SID}/pfile/init${ORACLE_SID}.ora
#pfile_11g=$ORACLE_ADMIN/${ORACLE_SID}/pfile/init${ORACLE_SID}.ora.11g
cp $pfile_10g $pfile_11g

sed -i "/^*.background_dump_dest/d" $pfile_11g
sed -i "/^*.user_dump_dest/d" $pfile_11g
