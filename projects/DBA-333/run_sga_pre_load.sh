#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 tdcsnp"
  echo
  exit
else
  export ORACLE_SID=$1
fi

. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
novausername=novaprd
novauserpwd=`get_user_pwd $tns $novausername`

echo "Starting .............................. "$0

#
# The database trigger to pre load the data cache will only execute on the
# production database (tdcprd) so now we need to manually execute the
# process to pre load the data cache.
#
sqlplus -s /nolog << EOF
connect / as sysdba
begin
	sga_pre_load.clear_flags;
	sga_pre_load.run_multi_thread( 2 );
end;
/

exit;
EOF

