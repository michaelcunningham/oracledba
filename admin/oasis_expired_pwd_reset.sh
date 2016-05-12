#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <username>"
  echo "	Example: $0 mcunning"
  echo
  exit 2
else
  export username=`echo $1 | awk '{print toupper($0)}'`
fi

. /dba/admin/dba.lib

# Get an ORACLE_SID (any one) so we can set the environment
ORACLE_SID=`ps -ef | grep pmon | grep -v "grep pmon" | cut -f3 -d_ | head -1`
OASIS_DB_SID=fprod

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%Y%m%d_%H%M%p`
admin_dir=/dba/admin
log_dir=$admin_dir/log
log_file=$log_dir/oasis_password_reset_$log_date.log

# Get the tns string
tns=`/dba/admin/get_tns_from_orasid.sh $OASIS_DB_SID`
retval=$?
if [ "$retval" != "0" ]
then
  echo "Could not find the tns string for "$OASIS_DB_SID
  exit $retval
fi

syspwd=`get_sys_pwd $tns`
retval=$?
if [ "$retval" != "0" ]
then
  echo "Could not find the sys password for "$OASIS_DB_SID
  exit $retval
fi

# Test section for variables
# echo "username        = "$username
# echo "log_file        = "$log_file
# echo "tns             = "$tns
# echo "syspwd          = "$syspwd
# echo "username_exists = "$username_exists

#
# Check to make sure the user actually exists
#
username_exists=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect sys/$syspwd@$tns as sysdba
select username from dba_users where username = '$username';
exit;
EOF`

username_exists=`echo $username_exists`

# echo "username_exists = "$username_exists

if [ "$username_exists" = "" ]
then
  echo
  echo "	The username "$username" does not exist in the fprod database."
  echo
  exit
fi

# If we made it this far we have determined that the user exists in the database
# so let's reset the password.
sqlplus -s /nolog << EOF
connect sys/$syspwd@$tns as sysdba

alter user $username profile default;
alter user $username identified by newpswd;
alter user $username identified by xMDVORVC;
alter user $username profile oasis;

exit;
EOF

echo '
     *****************************************************************
     *****                                                       *****
     *****                                                       *****'
printf "     *****  %-50s   *****" "The password for user $username has been reset."
echo '
     *****                                                       *****
     *****                                                       *****
     *****************************************************************
'
