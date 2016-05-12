#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 svdev"
  echo
  exit
fi

. /dba/admin/dba.lib

export ORACLE_SID=$1
export ORAENV_ASK=NO
username=perfstat
tns=`get_tns_from_orasid $ORACLE_SID`
userpwd=`get_user_pwd $tns $username`

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit 1
fi

. /usr/local/bin/oraenv

sqlplus -s /nolog << EOF
connect $username/$userpwd
begin
  statspack.snap;
end;
/
exit;
EOF

