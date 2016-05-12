#!/bin/sh

export ORACLE_SID=+ASM

pmon=`ps x | grep pmon_$ORACLE_SID  | grep -v grep`

if [ "$pmon" = "" ]
then
  echo "ASM is not running."
  exit
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect / as sysasm
shutdown immediate
exit;
EOF
