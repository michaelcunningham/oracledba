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

log_file=/mnt/dba/projects/asm_to_non_asm/logs/${ORACLE_SID}_step_4_switch_logfile.log

sqlplus -s /nolog << EOF | tee $log_file
connect / as sysdba
alter system switch logfile;
exit;
EOF
