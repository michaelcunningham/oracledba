#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <username>"
  echo
  echo "   Example: $0 tdcsnp novaprd"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

admin_dir=/dba/admin
log_file=${admin_dir}/log/${ORACLE_SID}_constaints_with_no_indexes_mk_ddl.log

echo
echo "	************************************************************"
echo
echo "	Results will be listed in log file:"
echo
echo "	"$log_file
echo
echo "	************************************************************"
echo

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba

@/dba/scripts/constraints_with_no_index_mk_ddl.sql $2

exit;
EOF

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

echo "See Attatchment" | mutt -s $1@$ORACLE_SID" - Constraints without indexes" mcunningham@thedoctors.com -a $log_file
#echo "See Attatchment" | mutt -s $1@$ORACLE_SID" - Constraints without indexes" swahby@thedoctors.com -a $log_file
