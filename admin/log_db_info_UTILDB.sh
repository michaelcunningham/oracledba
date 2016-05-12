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

unset SQLPATH
export ORACLE_SID=$1
# export PATH=/usr/local/bin:$PATH
export PATH="/usr/local/bin:"`echo $PATH | sed "s/\/usr\/local\/bin://g"`
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

instance_name=$1        # varchar2(16)

storage_name=`/mnt/dba/admin/get_storage_server_name.sh`
# data_volume_size=`/mnt/dba/admin/asm_get_data_volume_size.sh`
data_volume_size=`/mnt/dba/admin/get_db_data_file_size.sh $ORACLE_SID`
log_volume_size=`/mnt/dba/admin/asm_get_log_volume_size.sh`
listener_port=1521
server_name=`hostname -s`
vip_address=`/mnt/dba/admin/get_db_vip.sh $ORACLE_SID`
ip_address=`nslookup $server_name | grep Name -A1 | grep Address | awk '{print $2}'`
platform_version=`uname -r`

if [ -f "/etc/oracle-release" ]
then
  platform_release=`cat /etc/oracle-release`
else
  platform_release=`cat /etc/redhat-release`
fi

# echo
# echo 'instance_name               : '$instance_name
# echo 'storage_name                : '$storage_name
# echo 'data_volume_size            : '$data_volume_size
# echo 'log_volume_size             : '$log_volume_size
# echo 'listener_port               : '$listener_port
# echo 'server_name                 : '$server_name
# echo 'vip_address                 : '$vip_address
# echo 'ip_address                  : '$ip_address
# echo 'platform_version            : '$platform_version
# echo 'platform_release            : '$platform_release

tns=utildb
username=tag
userpwd=zx6j1bft

####################################################################################################
#
# I know this looks like a lot of work, but it so that the same thing works on standby databases
# which are not OPEN databases.
#
####################################################################################################

db_version=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select banner from v\\$version where banner like '%Database%';
exit;
EOF`

db_version=`echo $db_version`

sga_max_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'sga_max_size';
exit;
EOF`

sga_max_size=`echo $sga_max_size`

db_cache_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
--select value from v\\$parameter where name = 'db_cache_size';
select	decode( value, 0,
		(select y.ksppstvl value from x\\$ksppi x, x\\$ksppcv y where x.indx = y.indx and x.ksppinm = '__db_cache_size'), value )
from	v\\$parameter where name = 'db_cache_size';
exit;
EOF`

db_cache_size=`echo $db_cache_size`

shared_pool_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
--select value from v\\$parameter where name = 'shared_pool_size';
select	decode( value, 0, (select y.ksppstvl value from x\\$ksppi x, x\\$ksppcv y where x.indx = y.indx and x.ksppinm = '__shared_pool_size'), value )
from	v\\$parameter where name = 'shared_pool_size';
exit;
EOF`

shared_pool_size=`echo $shared_pool_size`

large_pool_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
--select value from v\\$parameter where name = 'large_pool_size';
select	decode( value, 0, (select y.ksppstvl value from x\\$ksppi x, x\\$ksppcv y where x.indx = y.indx and x.ksppinm = '__large_pool_size'), value )
from	v\\$parameter where name = 'large_pool_size';
exit;
EOF`

large_pool_size=`echo $large_pool_size`

java_pool_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
--select value from v\\$parameter where name = 'java_pool_size';
select	decode( value, 0, (select y.ksppstvl value from x\\$ksppi x, x\\$ksppcv y where x.indx = y.indx and x.ksppinm = '__java_pool_size'), value )
from	v\\$parameter where name = 'java_pool_size';
exit;
EOF`

java_pool_size=`echo $java_pool_size`

streams_pool_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
--select value from v\\$parameter where name = 'streams_pool_size';
select	decode( value, 0, (select y.ksppstvl value from x\\$ksppi x, x\\$ksppcv y where x.indx = y.indx and x.ksppinm = '__streams_pool_size'), value )
from	v\\$parameter where name = 'streams_pool_size';
exit;
EOF`

streams_pool_size=`echo $streams_pool_size`

shared_io_pool=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select nvl( max( bytes ), 0 ) from v\\$sgastat where name = 'shared_io_pool';
exit;
EOF`

shared_io_pool=`echo $shared_io_pool`

pga_aggregate_target=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'pga_aggregate_target';
exit;
EOF`

pga_aggregate_target=`echo $pga_aggregate_target`

db_keep_cache_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'db_keep_cache_size';
exit;
EOF`

db_keep_cache_size=`echo $db_keep_cache_size`

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

database_role=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select database_role from v\\$database;
exit;
EOF`

database_role=`echo $database_role`

platform_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select platform_name from v\\$database;
exit;
EOF`

platform_name=`echo $platform_name`

# echo $db_version
# echo $db_cache_size
# echo $pga_aggregate_target
# echo $db_keep_cache_size
# echo $db_unique_name
# echo $database_role
# echo $platform_name

####################################################################################################

# echo $username/$userpwd@$tns

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

set feedback off

declare
begin
	merge into db_info t
	using (
		select	'$db_unique_name' db_unique_name,
			'$instance_name' instance_name,
			'$database_role' database_role,
			'$db_version' db_version,
			'$db_cache_size' db_cache_size,
			'$pga_aggregate_target' pga_aggregate_target,
			'$db_keep_cache_size' db_keep_cache_size,
			'$platform_name' platform_name,
			'$platform_version' platform_version,
			'$platform_release' platform_release,
			'$storage_name' storage_name,
			'$data_volume_size' data_volume_size,
			'$log_volume_size' log_volume_size,
			'$listener_port' listener_port,
			'$server_name' server_name,
			'$vip_address' vip_address,
			'$ip_address' ip_address,
			'$sga_max_size' sga_max_size,
			'$shared_pool_size' shared_pool_size,
			'$large_pool_size' large_pool_size,
			'$java_pool_size' java_pool_size,
			'$streams_pool_size' streams_pool_size,
			'$shared_io_pool' shared_io_pool
		from	dual ) s
	on	( t.db_unique_name = s.db_unique_name )
	when matched then
		update
		set	instance_name = s.instance_name,
			database_role = s.database_role,
			db_version = s.db_version,
			db_cache_size = s.db_cache_size,
			pga_aggregate_target = s.pga_aggregate_target,
			db_keep_cache_size = s.db_keep_cache_size,
			platform_name = s.platform_name,
			platform_version = s.platform_version,
			platform_release = s.platform_release,
			storage_name = s.storage_name,
			data_volume_size = s.data_volume_size,
			log_volume_size = s.log_volume_size,
			listener_port = s.listener_port,
			server_name = s.server_name,
			vip_address = s.vip_address,
                        ip_address = s.ip_address,
			sga_max_size = s.sga_max_size,
			shared_pool_size = s.shared_pool_size,
			large_pool_size = s.large_pool_size,
			java_pool_size = s.java_pool_size,
			streams_pool_size = s.streams_pool_size,
			shared_io_pool = s.shared_io_pool
	when not matched then insert(
			db_unique_name, instance_name, database_role, db_version, db_cache_size,
			pga_aggregate_target, db_keep_cache_size, platform_name, platform_version,
			platform_release, storage_name, data_volume_size,
			log_volume_size, listener_port, server_name, vip_address, ip_address,
			sga_max_size, shared_pool_size, large_pool_size, java_pool_size,
			streams_pool_size, shared_io_pool )
		values(
			'$db_unique_name', s.instance_name, s.database_role, s.db_version, s.db_cache_size,
			s.pga_aggregate_target, s.db_keep_cache_size, s.platform_name, s.platform_version,
			s.platform_release, s.storage_name, s.data_volume_size,
			s.log_volume_size, s.listener_port, s.server_name, s.vip_address, s.ip_address,
			s.sga_max_size, s.shared_pool_size, s.large_pool_size, s.java_pool_size,
			s.streams_pool_size, s.shared_io_pool );

	commit;

end;
/

exit;
EOF
