#!/bin/bash

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

db_unique_name=`srvctl config database | grep $ORACLE_SID`

if [ -z $db_unique_name ]
then
db_unique_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select db_unique_name from v\\$database;
exit;
EOF`
db_unique_name=`echo $db_unique_name`
fi

# For now this is being set to detect if version 12.1.0.2.0 is being used.
# If it is then we will do things a little bit differently
# The following will return the 2 in 12.1.0.2.0
srvctl_version=`srvctl -V | cut -d: -f2 | cut -d. -f4`

# Make a | delimited string
asm_info=`srvctl config database -db $db_unique_name | tr '\n' '|'`
# db_unique_name=`echo $asm_info | cut -d'|' -f1 | cut -d':' -f2`
db_name=`echo $asm_info | cut -d'|' -f2 | cut -d':' -f2`
db_home=`echo $asm_info | cut -d'|' -f3 | cut -d':' -f2`
db_user=`echo $asm_info | cut -d'|' -f4 | cut -d':' -f2`
db_spfile=`echo $asm_info | cut -d'|' -f5 | cut -d':' -f2`
db_pwfile=`echo $asm_info | cut -d'|' -f6 | cut -d':' -f2`
db_domain=`echo $asm_info | cut -d'|' -f7 | cut -d':' -f2`
db_startoptions=`echo $asm_info | cut -d'|' -f8 | cut -d':' -f2`
db_stopoptions=`echo $asm_info | cut -d'|' -f9 | cut -d':' -f2`
db_role=`echo $asm_info | cut -d'|' -f10 | cut -d':' -f2`
db_policy=`echo $asm_info | cut -d'|' -f11 | cut -d':' -f2`

if [ "$srvctl_version" = "2" ]
then
  db_instance_name=`echo $asm_info | cut -d'|' -f16 | cut -d':' -f2`
  db_diskgroup=`echo $asm_info | cut -d'|' -f12 | cut -d':' -f2`
else
  db_instance_name=`echo $asm_info | cut -d'|' -f12 | cut -d':' -f2`
  db_diskgroup=`echo $asm_info | cut -d'|' -f13 | cut -d':' -f2`
fi

db_services=`echo $asm_info | cut -d'|' -f14 | cut -d':' -f2`

# chomp all the variables
db_name=`echo $db_name`
db_home=`echo $db_home`
db_user=`echo $db_user`
db_spfile=`echo $db_spfile`
db_pwfile=`echo $db_pwfile`
db_domain=`echo $db_domain`
db_startoptions=`echo $db_startoptions`
db_stopoptions=`echo $db_stopoptions`
db_role=`echo $db_role`
db_policy=`echo $db_policy`
db_instance_name=`echo $db_instance_name`
db_diskgroup=`echo $db_diskgroup`
db_services=`echo $db_services`

# echo $asm_info
# echo "db_unique_name    = "$db_unique_name
# echo "db_name           = "$db_name
# echo "db_home           = "$db_home
# echo "db_user           = "$db_user
# echo "db_spfile         = "$db_spfile
# echo "db_pwfile         = "$db_pwfile
# echo "db_domain         = "$db_domain
# echo "db_startoptions   = "$db_startoptions
# echo "db_stopoptions    = "$db_stopoptions
# echo "db_role           = "$db_role
# echo "db_policy         = "$db_policy
# echo "db_instance_name  = "$db_instance_name
# echo "db_diskgroup      = "$db_diskgroup
# echo "db_services       = "$db_services

tns=whse
username=taggedmeta
userpwd=taggedmeta123

db_name=`echo $db_name`
db_home=`echo $db_home`
db_spfile=`echo $db_spfile`
db_pwfile=`echo $db_pwfile`
db_domain=`echo $db_domain`
db_startoptions=`echo $db_startoptions`
db_stopoptions=`echo $db_stopoptions`
db_role=`echo $db_role`
db_policy=`echo $db_policy`
db_instance_name=`echo $db_instance_name`
db_diskgroup=`echo $db_diskgroup`
db_services=`echo $db_services`

####################################################################################################
#
# Record the CPU Time.
#
####################################################################################################
sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

set feedback off

declare
begin
	merge into has_db_info t
	using (
		select	'$db_unique_name' db_unique_name,
			'$db_name' db_name, '$db_instance_name' instance_name,
			'$db_home' home, '$db_user' oracle_user,
			'$db_spfile' spfile, '$db_pwfile' password_file,
			'$db_domain' domain, '$db_startoptions' start_options,
			'$db_stopoptions' stop_options, '$db_role' database_role,
			'$db_policy' management_policy, '$db_diskgroup' diskgroups,
			'$db_services' services
		from	dual ) s
	on	( t.db_unique_name = s.db_unique_name )
	when matched then
		update
		set	db_name = s.db_name,
			instance_name = s.instance_name,
			home = s.home,
			oracle_user = s.oracle_user,
			spfile = s.spfile,
			password_file = s.password_file,
			domain = s.domain,
			start_options = s.start_options,
			stop_options = s.stop_options,
			database_role = s.database_role,
			management_policy = s.management_policy,
			diskgroups = s.diskgroups,
			services = s.services
	when not matched then insert(
			db_unique_name, db_name, instance_name,
			home, oracle_user, spfile,
			password_file, domain, start_options,
                        stop_options, database_role, management_policy,
			diskgroups, services )
		values(
			s.db_unique_name, s.db_name, s.instance_name,
			s.home, s.oracle_user, s.spfile,
			s.password_file, s.domain, s.start_options,
                        s.stop_options, s.database_role, s.management_policy,
			s.diskgroups, s.services );
	commit;

end;
/

exit;
EOF
