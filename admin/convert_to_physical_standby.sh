#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <ORACLE_SID>"
  echo "	Example: $0 tdcphy2"
  echo
  exit 2
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%a`

sqlplus /nolog << EOF
connect / as sysdba
shutdown immediate
startup mount
exit;
EOF

#
# Get the SCN we need to flashback to
#
flashback_scn=`sqlplus -s /nolog << EOF
set heading off
column standby_became_primary_scn format 999999999999999
connect / as sysdba
select standby_became_primary_scn from v\\$database;
exit;
EOF`

flashback_scn=`echo $flashback_scn`

#echo $flashback_scn

#if [ "$flashback_scn" != "PHYSICAL STANDBY" ]
#then
#  echo
#  echo "	This is not a physical standby database and cannot be activated."
#  echo
#  exit
#fi

sqlplus /nolog << EOF
connect / as sysdba
flashback database to scn $flashback_scn;
alter database convert to physical standby;
shutdown immediate
startup mount
alter database recover managed standby database disconnect from session;
exit;
EOF

