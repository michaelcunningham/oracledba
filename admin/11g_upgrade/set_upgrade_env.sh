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

export pfile_dir=$ORACLE_ADMIN/$ORACLE_SID/pfile
export pfile_10g=$pfile_dir/init${ORACLE_SID}.ora.10g
export pfile_11g=$pfile_dir/init${ORACLE_SID}.ora.11g
export ORACLE_HOME_11g=/oracle/app/oracle/product/11.2.0/dbhome_2
