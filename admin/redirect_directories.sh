#!/bin/sh

# This was done to setup the rating directories.
#
# rsh npnetapp104 exportfs -p rw,root=npdb520-10g /vol/tdcrt2
# rsh npnetapp104 qtree create /vol/tdcrt2/rating
# rsh npnetapp104 qtree security /vol/tdcrt2/rating mixed
# rsh npnetapp104 cifs shares -add tdcrt2external /vol/tdcrt2/rating
#
# NOW WE HAVE TO LOGIN AS ROOT
# chown oracle.oinstall /tdcrt2/rating
#
# NOW WE CAN GO BACK TO ORACLE LOGIN
# chmod o+rwx /tdcrt2/rating
#
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
log_file=$log_dir/redirect_directories_$log_date.log

# mkdir -p /$ORACLE_SID/external/rating
# chmod 2777 /$ORACLE_SID/external/rating

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba

create or replace directory external_data as '/$ORACLE_SID/external';
create or replace directory data_pump_dir as '/oracle/app/oracle/admin/$ORACLE_SID/dpdump/';
create or replace directory rating_data as '/$ORACLE_SID/rating';
grant read, write on directory rating_data to novaprd;

exit;
EOF

filer_name=`df -P -m | grep $ORACLE_SID$ | cut -d: -f1 | uniq`

rsh $filer_name cifs shares -add ${ORACLE_SID}ext /vol/$ORACLE_SID/external
rsh $filer_name cifs shares -add ${ORACLE_SID}external /vol/$ORACLE_SID/rating
