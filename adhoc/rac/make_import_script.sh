#! /bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <to_ORACLE_SID>"
  echo
  echo "   Example: $0 TDB00 TDB01"
  echo
  exit
fi

to_ORACLE_SID=$2

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

work_file=/mnt/dba/adhoc/rac/file_count.lst
import_file=/mnt/dba/adhoc/rac/import_${ORACLE_SID}_to_${to_ORACLE_SID}.sh

echo
echo "	Creating import file..."
echo

for this_file in $(cat $work_file)
do
  if [ -n "$data_files" ]
  then
    data_files=$data_files","
  fi
  data_files=$data_files"'"$this_file"'"
done

echo imp userid=\\\"/ as sysdba\\\" transport_tablespace=y \\ > $import_file
echo datafiles=$data_files" \\" >> $import_file
echo file=/mnt/dba/adhoc/rac/${ORACLE_SID}_transport.dmp" \\" >>  $import_file
echo log=/mnt/dba/adhoc/rac/${ORACLE_SID}_transport.log >>  $import_file

chmod u+x $import_file
cat $import_file
