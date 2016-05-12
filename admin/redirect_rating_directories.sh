#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID>"
  echo
  echo "	Example : $0 tdccpy"
  echo
  exit
fi

export ORACLE_SID=$1

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/redirect_rating_directories_$log_date.log

# Create the directory for the rating files.
mkdir -p /$ORACLE_SID/external/rating
chmod 2777 /$ORACLE_SID/external/rating

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba

create or replace directory rating_data as '/$ORACLE_SID/external/rating';
grant read on directory rating_data to novaprd;

exit;
EOF

filer_name=`df -P -m | grep $ORACLE_SID | cut -d: -f1 | uniq`

rsh $filer_name cifs shares -add ${ORACLE_SID}rating /vol/$ORACLE_SID/external/rating
