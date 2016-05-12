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

log_file=/mnt/dba/logs/$ORACLE_SID/recover_db_after_snapshot.log

sqlplus /nolog << EOF
connect / as sysdba
startup mount
alter database flashback off;
exit;
EOF

rman target / << EOF
catalog start with '/mnt/oralogs2/$ORACLE_SID/rman_bkup' noprompt;
--catalog start with '/mnt/oralogs2/$ORACLE_SID' noprompt;
quit
EOF

sqlplus /nolog << EOF
connect / as sysdba

-- if it doesn't work use
--recover database using backup controlfile until cancel;
recover database until cancel;
auto
alter database open resetlogs;
shutdown immediate
startup

exit;
EOF
