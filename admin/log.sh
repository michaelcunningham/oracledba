#!/bin/sh

export ORACLE_SID=`ps -ef | grep pmon | grep -v "grep pmon" | cut -f3 -d_ | head -1`
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

db_version=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select	case
		when instr( banner, 'Enterprise' ) > 0 then
			'Enterprise Edition'
		when instr( banner, 'Enterprise' ) = 0 then
			'Standard Edition'
	end case
from	v\\$version where banner like '%Database%';
exit;
EOF`

echo 'db_version                  : '$db_version
echo

