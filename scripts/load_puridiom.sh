#!/bin/sh

#
# This must be run first to create the external directory with the correct permissions
# on the filer.
#     /oracle/app/oracle/admin/dwdev/create/create_external_data_directory.sh
#
# /oracle/app/oracle/admin/dwdev/create/create_tdcuser_user.sh $ORACLE_SID
# /oracle/app/oracle/admin/dwdev/export/impdp_tdcuser.sh
# /oracle/app/oracle/admin/dwdev/create/privs_tdcpo.sh
#
# Don't forget to create the tdcpo user
#

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 dwdev"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

log_date=`date +%Y%m%d`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/load_puridiom_$log_date.log

ext_dir=/$ORACLE_SID/external
dataload_dir=$ext_dir/dataload
ext_gz_file=$dataload_dir/puridiom.gz
load_file_name=$dataload_dir/puridiom_data.dmp

if [ ! -f $ext_gz_file ]
then
  result=2
  exit $result
fi

gunzip $ext_gz_file
ext_file_name=`ls -rt1 $dataload_dir | tail -1`
#echo $ext_file_name

# Rename the extracted file to a standard name we need so we can use it with data pump.
#echo $ext_dir/$ext_file_name
#echo $load_file_name
#echo "move "$dataload_dir/$ext_file_name" to "$load_file_name
mv $dataload_dir/$ext_file_name $load_file_name

mkdir -p /$ORACLE_SID/external/archive
#echo $load_file_name
#echo $ext_dir/archive/puridiom_data_$log_date.dmp
#echo "copy "$load_file_name" to "$ext_dir/archive/puridiom_data_$log_date.dmp
cp $load_file_name $ext_dir/archive/puridiom_data_$log_date.dmp

/dba/admin/kill_all_username.sh $ORACLE_SID tdcuser
/oracle/app/oracle/admin/dwdev/create/create_tdcuser_user.sh $ORACLE_SID
/oracle/app/oracle/admin/dwdev/export/impdp_tdcuser.sh

# Now that the load is complete we want to move the log file left behind by data pump
# to a log directory.  The name of this file is listed in the *.par file used
# by data pump.
mkdir -p /$ORACLE_SID/external/log
mv $dataload_dir/puridiom_data_load.log $ext_dir/log/puridiom_data_load_$log_date.log

# Now we need to grant permissions to the TDCPO user for the TDCUSER objects.
/oracle/app/oracle/admin/dwdev/create/privs_tdcpo.sh

sqlplus -s /nolog << EOF >> $log_file
connect / as sysdba
@utlrp
exit;
EOF

