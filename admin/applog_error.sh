#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <message> <process_name> <process_info>"
  echo
  echo "   Example: $0 \"CLONE FAILED\" \"Clone Database\" \"tdcprd to tdcsnp\""
  echo
  echo "   Optional: $0 <message> <process_name> <process_info> <trace_brief> <trace_detail>"
  echo
  exit
fi

message_brief=$1  # This should be a brief (15 chars) piece of data such as the ORACLE_SID
process_name=$2   # This should be what was happening such as a database backup or clone
process_info=$3   # This could be the database being backed up, or clone source and target (ORACLE_SID)
trace_brief=$4    # This can be a brief description to operator such as "Notify the DBA"
trace_detail=$5   # This can be a a longer description of the problem and maybe something to do about it

. /dba/admin/dba.lib

#
# We need an ORACLE_SID to use so we can set the environment.  Let's find one.
# Since this script can be run from any Linux server we need to do this dynamically
# because we don't know which instance to use up front.
#
export ORACLE_SID=`ps -ef | grep ora_pmon | grep -v "grep ora_pmon"| awk '{print $8}' | awk -F_ '{print $3}' | head -1`
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

#tns=npdb530.tdc.internal:1539/apex.tdc.internal
#tns=npdb100.tdc.internal:1522/tdcprimary.tdc.internal
tns=tdcprd
username=tdcglobal
userpwd=`get_user_pwd $tns $username`

sqlplus -s $username/$userpwd@$tns << EOF
begin
	app_log_pkg.log_app_error_prc( 'DBA',
		'$process_name', '$process_info', '$message_brief', '$trace_brief', '$trace_detail' );
end;
/
exit;
EOF

