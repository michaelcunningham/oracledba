#!/bin/sh

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

instance_name=$1        # varchar2(16)

filer_name=`get_filer $instance_name`
data_volume_size=`rsh $filer_name vol size $ORACLE_SID | awk '{print $8}' | awk '{sub(/\./,"");print$0}'`
log_volume_size=`rsh $filer_name vol size ${ORACLE_SID}arch | awk '{print $8}' | awk '{sub(/\./,"");print$0}'`
data_volume_aggregate=`rsh $filer_name vol status ${ORACLE_SID} | grep "Containing aggregate" | tr -d "'" | awk '{print $3}'`
arch_volume_aggregate=`rsh $filer_name vol status ${ORACLE_SID}arch | grep "Containing aggregate" | tr -d "'" | awk '{print $3}'`
listener_port=`/dba/admin/get_listener_port.sh $ORACLE_SID`
server_name=`hostname | cut -d. -f1`
platform_version=`uname -r`

if [ -f "/etc/oracle-release" ]
then
  platform_release=`cat /etc/oracle-release`
else
  platform_release=`cat /etc/redhat-release`
fi

echo
echo 'instance_name               : '$instance_name
echo 'filer_name                  : '$filer_name
echo 'data_volume_size            : '$data_volume_size
echo 'log_volume_size            : '$log_volume_size
echo 'data_volume_aggregate       : '$data_volume_aggregate
echo 'arch_volume_aggregate       : '$arch_volume_aggregate
echo 'listener_port               : '$listener_port
echo 'server_name                 : '$server_name
echo 'platform_version            : '$platform_version
echo 'platform_release            : '$platform_release

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=tdce
userpwd=tdce

sqlplus -s /nolog << EOF
connect / as sysdba

set feedback off

create database link to_dba_data
connect to tdce identified by tdce
using 'npdb530.tdc.internal:1539/apex.tdc.internal';

declare
	s_instance_name		v\$instance.instance_name%type;
	s_db_version		v\$version.banner%type;
	n_db_cache_size		integer;
	n_pga_aggregate_target	integer;
	n_db_keep_cache_size	integer;
	s_platform_name		varchar2(101);
begin
	select banner into s_db_version from v\$version where banner like '%Database%';
	select value into n_db_cache_size from v\$parameter where name = 'db_cache_size';
	select value into n_pga_aggregate_target from v\$parameter where name = 'pga_aggregate_target';
	select value into n_db_keep_cache_size from v\$parameter where name = 'db_keep_cache_size';
	select platform_name into s_platform_name from v\$database;

	merge into db_info@to_dba_data t
	using (
		select	'$instance_name' instance_name,
			s_db_version db_version,
			n_db_cache_size db_cache_size,
			n_pga_aggregate_target pga_aggregate_target,
			n_db_keep_cache_size db_keep_cache_size,
			s_platform_name platform_name,
			'$platform_version' platform_version,
			'$platform_release' platform_release,
			'$filer_name' filer_name,
			'$data_volume_size' data_volume_size,
			'$log_volume_size' log_volume_size,
			'$data_volume_aggregate' data_volume_aggregate,
			'$arch_volume_aggregate' arch_volume_aggregate,
			'$listener_port' listener_port,
			'$server_name' server_name
		from	dual ) s
	on	( t.instance_name = s.instance_name )
	when matched then
		update
		set	db_version = s.db_version,
			db_cache_size = s.db_cache_size,
			pga_aggregate_target = s.pga_aggregate_target,
			db_keep_cache_size = s.db_keep_cache_size,
			platform_name = s.platform_name,
			platform_version = s.platform_version,
			platform_release = s.platform_release,
			filer_name = s.filer_name,
			data_volume_size = s.data_volume_size,
			log_volume_size = s.log_volume_size,
			data_volume_aggregate = s.data_volume_aggregate,
			arch_volume_aggregate = s.arch_volume_aggregate,
			listener_port = s.listener_port,
			server_name = s.server_name
	when not matched then insert(
			instance_name, db_version, db_cache_size,
			pga_aggregate_target, db_keep_cache_size, platform_name,
			platform_version, platform_release, filer_name,
			data_volume_size, log_volume_size, data_volume_aggregate,
			arch_volume_aggregate, listener_port, server_name )
		values(
			'$instance_name', s.db_version, s.db_cache_size,
			s.pga_aggregate_target, s.db_keep_cache_size, s.platform_name,
			s.platform_version, s.platform_release, s.filer_name,
			s.data_volume_size, s.log_volume_size, s.data_volume_aggregate,
			s.arch_volume_aggregate, s.listener_port, s.server_name );

	commit;

end;
/

drop database link to_dba_data;

exit;
EOF
