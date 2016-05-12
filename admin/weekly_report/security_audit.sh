#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <tns>"
  echo
  echo "        Example : $0 novadev"
  echo
  exit
fi

export tns=$1
username=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

sysuser=sys
sysuserpwd=`get_sys_pwd $tns`

echo `echo $tns | awk '{print toupper($0)}'`" - NOVAPRD - Security Audit"
echo "  If there is no data shown below then there were no security violations found in "`echo $tns | awk '{print toupper($0)}'`
echo

sqlplus -s /nolog << EOF
connect $sysuser/$sysuserpwd@$tns as sysdba

set serveroutput on
set feedback off
set tab off

column grantee        format a30     heading 'Grantee'
column granted_role   format a30     heading 'Granted Role'
column privilege      format a30     heading 'Privilege'
column admin_option   format a5      heading 'Admin'

--
-- Check for users who have system privileges
-- The values used on the "privilege" column were provided by E and Y during
-- the 2013 audit. I added some as well starting with 'ALTER ANY INDEX'.
--
select	grantee, privilege, admin_option
from	dba_sys_privs 
where	privilege in( 'CREATE USER', 'BECOME USER', 'ALTER USER',
		'DROP USER', 'CREATE ROLE', 'ALTER ANY ROLE',
		'DROP ANY ROLE', 'GRANT ANY ROLE', 'CREATE PROFILE',
		'ALTER PROFILE', 'DROP PROFILE', 'CREATE ANY TABLE',
		'ALTER ANY TABLE', 'DROP ANY TABLE', 'INSERT ANY TABLE',
		'UPDATE ANY TABLE', 'DELETE ANY TABLE', 'CREATE ANY PROCEDURE',
		'ALTER ANY PROCEDURE', 'DROP ANY PROCEDURE', 'CREATE ANY TRIGGER',
		'ALTER ANY TRIGGER', 'DROP ANY TRIGGER', 'CREATE TABLESPACE',
		'ALTER TABLESPACE', 'DROP TABLESPACES', 'ALTER DATABASE',
		'ALTER SYSTEM', 'ALTER ANY INDEX', 'ALTER ANY SEQUENCE',
		'CREATE ANY JOB' )
and	grantee not in( 'SYS', 'DBA', 'DATAPUMP_EXP_FULL_DATABASE',
		'DATAPUMP_IMP_FULL_DATABASE', 'IMP_FULL_DATABASE', 'EXP_FULL_DATABASE',
		'SCHEDULER_ADMIN', 'OLAP_DBA' )
minus
select  grantee, privilege, admin_option
from    dba_sys_privs
where   ( grantee = 'NOVAPRD' and privilege = 'ALTER SYSTEM' )
order by 1;

--
-- Check for users who have elevated role privileges
--
select	grantee, granted_role, admin_option
from	dba_role_privs
where	granted_role = 'DBA'
and	grantee not in( 'SYS', 'SYSTEM' )
union
select	grantee, granted_role, admin_option
from	dba_role_privs
where	granted_role in( 'EXP_FULL_DATABASE', 'DATAPUMP_EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
		'DATAPUMP_IMP_FULL_DATABASE', 'SCHEDULER_ADMIN' )
and	grantee not in( 'SYS', 'DBA', 'DATAPUMP_EXP_FULL_DATABASE', 'DATAPUMP_IMP_FULL_DATABASE' )
minus
select	grantee, granted_role, admin_option
from	dba_role_privs 
where	( grantee = 'REIN' and granted_role = 'DBA' )
or	( grantee = 'VISTAPRD' and granted_role = 'DBA' )
order by 1, 2;

exit;
EOF

