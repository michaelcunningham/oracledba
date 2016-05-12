#!/bin/sh

################################################################################
#
# This file is designed to run the install.sql which is located in the
# C:\Program Files (x86)\Quest Software\Spotlight\Plug-ins\So0\OracleScripts
# That install.sql file is copied to the /dba/admin/install_spotlight.sql file
# and is executed here to install the spotadm user and the objects.
#
# If Spotlight is ever upgraded we should be able to copy a new install.sql
# file to /dba/admin/install_spotlight.sql and we should be fine.
#
# REMINDER: When copying the install.sql script we need to open the file and
#           comment the line that connects to the database.  That connect will
#           not work because the listener is down when this script is run
#           during the post_restore.sh script.
#
################################################################################
if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_file=${adhoc_dir}/log/${ORACLE_SID}_install_spotlight_${log_date}.txt

tns=`get_tns_from_orasid $ORACLE_SID`
sysuser=sys
sysuserpwd=`get_sys_pwd $tns`

spotadmuser=spotadm
spotadmpwd=$sysuserpwd
default_tbs=sysaux
temp_tbs=temp

sqlplus -s /nolog << EOF > $log_file
connect sys/$syspwd as sysdba

set verify off

column get_dba_name noprint new_value dba_name
column get_dba_password noprint new_value dba_password
column get_connect_string noprint new_value connect_string
column get_repository_owner noprint new_value repository_owner
column get_repository_password noprint new_value repository_password
column get_default_tablespace noprint new_value default_tablespace
column get_temp_tablespace noprint new_value temp_tablespace

select '$sysuser' get_dba_name from dual;
select '$sysuserpwd' get_dba_password from dual;
select '$ORACLE_SID' get_connect_string from dual;
select '$spotadmuser' get_repository_owner from dual;
select '$spotadmpwd' get_repository_password from dual;
select '$default_tbs' get_default_tablespace from dual;
select '$temp_tbs' get_temp_tablespace from dual;

drop user &&repository_owner cascade;

@/dba/admin/install_spotlight.sql

exit;
EOF

