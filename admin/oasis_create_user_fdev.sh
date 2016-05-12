#!/bin/sh

if [ "$1" == "" ]
then
  echo
  echo "   Usage: $0 <new_username>"
  echo
  echo "   Example: $0 mcunning"
  echo
  exit 1
fi

export ORACLE_SID=fdev
export new_username=$1

. /dba/admin/dba.lib

# Get the tns string
tns=`/dba/admin/get_tns_from_orasid.sh $ORACLE_SID`
retval=$?
if [ "$retval" != "0" ]
then
  echo "Could not find the tns string for "$ORACLE_SID
  exit $retval
fi

syspwd=`get_sys_pwd $tns`
retval=$?
if [ "$retval" != "0" ]
then
  echo "Could not find the sys password for "$ORACLE_SID
  exit $retval
fi

#
# Check to see if the user exists
# If so, then exit
#
user_exists=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect sys/$syspwd@$tns as sysdba
select username from dba_users where username = upper( '$new_username' );
exit;
EOF`

user_exists=`echo $user_exists`

if [ "$user_exists" != "" ]
then
  echo
  echo "        ####################################################################"
  echo
  echo "        The user "$new_username" already exists."
  echo
  echo "        Exiting..."
  echo
  echo "        ####################################################################"
  echo
  sleep 5
  exit
fi

#
# Create the new user.
#
sqlplus /nolog << EOF
connect sys/$syspwd@$tns as sysdba

create user $new_username
identified by welcome1
default tablespace oasis_data
temporary tablespace temp
quota 1024k on oasis_data;

grant create session to $new_username;
grant oasis_user to $new_username;

grant developer to $new_username;
grant develop2 to $new_username;

update fpicusr.pfuser
set department = 'IT'
where userid = upper( '$new_username' );
commit;

exit;
EOF
