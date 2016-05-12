#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

. /dba/admin/dba.lib

source_db=$1
schema_name=$2
username=dmmaster
tns=apex
userpwd=`get_user_pwd $tns $username`

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

pfile_name=$ORACLE_ADMIN/$ORACLE_SID/pfile/init${ORACLE_SID}.ora
pfile_name_oh=$ORACLE_HOME/dbs/init${ORACLE_SID}.ora

if [ -f $pfile_name_oh ]
then
  cp $pfile_name_oh ${pfile_name_oh}.temp
fi

if [ -h $pfile_name ]
then
  echo $pfile_name" is a symbolic link"
  rm $pfile_name
fi

if [ -h $pfile_name_oh ]
then
  echo $pfile_name_oh" is a symbolic link"
  rm $pfile_name
fi

cp ${pfile_name_oh}.temp $pfile_name
rm $pfile_name_oh
ln -s $pfile_name $pfile_name_oh
