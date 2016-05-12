#! /bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

ORACLE_SID_DB=$ORACLE_SID
export ORACLE_SID=+ASM
. /usr/local/bin/oraenv -s

for i in {1..10}
do
  asmcmd cp +STAGEDATA/$ORACLE_SID_DB/log${i}.ora /mnt/db_transfer/$ORACLE_SID_DB/logs
done
