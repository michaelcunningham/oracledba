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

. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
username=novaprd
userpwd=`get_user_pwd $tns $username`

log_file=/dba/admin/11g_upgrade/log/clob_compress_${ORACLE_SID}.log
> $log_file

# sqlplus -s /nolog << EOF >> $log_file
# connect / as sysdba
# alter tablespace nova_lob add datafile '/$ORACLE_SID/oradata/nova_lob02.dbf' size 1g autoextend on next 1g maxsize unlimited;
# exit;
# EOF

echo "Start of compress "`date` >> $log_file
echo >> $log_file

sqlplus /nolog << EOF >> $log_file
connect $username/$userpwd
@/dba/admin/11g_upgrade/NOV_CD34987_COMPRESS_XML.SQL
exit;
EOF

echo >> $log_file
echo "End of compress   "`date` >> $log_file
echo >> $log_file

dp 4/Compress complete in ${ORACLE_SID}

