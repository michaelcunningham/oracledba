#!/bin/sh

. /dba/admin/dba.lib

#
# We need an ORACLE_SID to use so we can set the environment.  Let's find one.
# Since this script can be run from any Linux server we need to do this dynamically
# because we don't know which instance to use up front.
#
export ORACLE_SID=`ps -ef | grep ora_pmon | grep -v "grep ora_pmon"| awk '{print $8}' | awk -F_ '{print $3}' | head -1`
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=tdcgld
username=vista_admin
userpwd=`get_user_pwd $tns $username`

sqlplus -s $username/$userpwd@$tns << EOF

set pagesize 60
set linesize 130
column db_name format a10
column parameter format a10
column value format a100

select	sys_db_connect_string db_name, sys_db_env_param_type_code parameter,
	db_environment_value value
from	lu_sys_db_env_param
where	sys_db_env_param_type_code = 'MP_URL'
order by sys_db_connect_string;

exit;
EOF

