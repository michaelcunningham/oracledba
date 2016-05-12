#!/bin/sh

server_name=`hostname -s`
ip_address=`nslookup $server_name | grep Name -A1 | grep Address | awk '{print $2}'`
platform_version=`uname -r`

if [ -f "/etc/oracle-release" ]
then
  platform_release=`cat /etc/oracle-release`
else
  platform_release=`cat /etc/redhat-release`
fi

cpu_socket_count=`cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l`
cpu_cores_per_socket=`cat /proc/cpuinfo | grep "cpu cores" | uniq | cut -d: -f2 | sed 's/^ //g'`
cpu_cache_size=`cat /proc/cpuinfo | grep "cache size" | uniq | cut -d: -f2 | sed 's/^ //g'`
cpu_siblings=`cat /proc/cpuinfo | grep "siblings" | uniq | cut -d: -f2 | sed 's/^ //g'`

answer=`echo $(($cpu_cores_per_socket*2))`
if [ $answer -eq $cpu_siblings ]
then
  is_hyperthreaded="Yes"
else
  is_hyperthreaded="No"
fi

cpu_model=`cat /proc/cpuinfo | grep "model name" | uniq | cut -d: -f2 | xargs`
cpu_speed=`cat /proc/cpuinfo | grep "cpu MHz" | uniq | cut -d: -f2 | xargs`" MHz"
total_ram=`cat /proc/meminfo | grep "MemTotal" | cut -d: -f2 | xargs`
total_ram_num=`echo $total_ram | tr -d ' kB'`
total_ram_gb=`echo $(($total_ram_num/1024/1024))`" GB"
huge_memory_pages=`cat /proc/meminfo | grep "HugePages_Total" | cut -d: -f2 | xargs`
huge_memory_size_gb=`echo $(($huge_memory_pages*2/1024))`" GB"
data_volume_size=`/mnt/dba/admin/asm_get_data_volume_size.sh`
log_volume_size=`/mnt/dba/admin/asm_get_log_volume_size.sh`

# Just pick the first ORACLE_SID we can find that is running.
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB" | sort | head -1`

if [ -z $ORACLE_SID ]
then
  # There is no database running on this server.  Just exit.
  exit
fi

ORAENV_ASK=NO . /usr/local/bin/oraenv -s

db_edition=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select  case
                when instr( banner, 'Enterprise' ) > 0 then
                        'Enterprise Edition'
                when instr( banner, 'Enterprise' ) = 0 then
                        'Standard Edition'
        end case
from    v\\$version where banner like '%Database%';
exit;
EOF`

db_edition=`echo $db_edition`

db_version=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba

select	replace( replace( replace( banner, 'CORE' ), 'Production' ), '	' ) db_version
from	v\\$version
where	banner like '%CORE%';

exit;
EOF`

db_version=`echo $db_version`

if [ "$db_edition" = "Enterprise Edition" ]
then
  cpu_licenses_used=`echo $(($cpu_socket_count*$cpu_cores_per_socket/2))`
  oracle_licenses_being_used=$cpu_licenses_used" Enterprise CPU licenses"
else
  standard_licenses_used=`echo $(($cpu_socket_count))`
  oracle_licenses_being_used=$standard_licenses_used" Standard edition licenses"
fi

# Build a list of databases running on this server.
#
sid_list=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB" | sort`

for this_sid in $sid_list
do
  if [ ! -z $instance_name_all ]
  then
    instance_name_all=$instance_name_all","
  fi
  instance_name_all=$instance_name_all$this_sid
done

# echo
# echo 'server_name                 : '$server_name
# echo 'ip_address                  : '$ip_address
# echo 'platform_version            : '$platform_version
# echo 'platform_release            : '$platform_release
# echo 'cpu_socket_count            : '$cpu_socket_count
# echo 'cpu_cores_per_socket        : '$cpu_cores_per_socket
# echo 'cpu_cache_size              : '$cpu_cache_size
# echo 'cpu_siblings                : '$cpu_siblings
# echo 'is_hyperthreaded            : '$is_hyperthreaded
# echo 'cpu_model                   : '$cpu_model
# echo 'cpu_speed                   : '$cpu_speed
# echo 'total_ram                   : '$total_ram
# echo 'total_ram_gb                : '$total_ram_gb
# echo 'huge_memory_pages           : '$huge_memory_pages
# echo 'huge_memory_size_gb         : '$huge_memory_size_gb
# echo 'db_edition                  : '$db_edition
# echo 'db_version                  : '$db_version
# echo 'cpu_licenses_used           : '$cpu_licenses_used
# echo 'standard_licenses_used      : '$standard_licenses_used
# echo 'oracle_licenses_being_used  : '$oracle_licenses_being_used
# echo 'data_volume_size            : '$data_volume_size
# echo 'log_volume_size             : '$log_volume_size
# echo 'instance_name               : '$ORACLE_SID
# echo 'instance_name_all           : '$instance_name_all
# echo

####################################################################################################
#
# The following requires SUID permissions on the /usr/sbin/dmidecode file
# chmod u+s /usr/sbin/dmidecode
#
# The servers at if(we) have empty DMI Tables so this does not work.  Comment the code.
####################################################################################################

# bios_vendor=`/usr/sbin/dmidecode -s bios-vendor`
# bios_version=`/usr/sbin/dmidecode -s bios-version`
# bios_release_date=`/usr/sbin/dmidecode -s bios-release-date`
# system_manufacturer=`/usr/sbin/dmidecode -s system-manufacturer`
# system_product_name=`/usr/sbin/dmidecode -s system-product-name`
# system_version=`/usr/sbin/dmidecode -s system-version`
# system_serial_number=`/usr/sbin/dmidecode -s system-serial-number`
# system_uuid=`/usr/sbin/dmidecode -s system-uuid`
# baseboard_manufacturer=`/usr/sbin/dmidecode -s baseboard-manufacturer`
# baseboard_product_name=`/usr/sbin/dmidecode -s baseboard-product-name`
# baseboard_version=`/usr/sbin/dmidecode -s baseboard-version`
# baseboard_serial_number=`/usr/sbin/dmidecode -s baseboard-serial-number`
# baseboard_asset_tag=`/usr/sbin/dmidecode -s baseboard-asset-tag`
# chassis_manufacturer=`/usr/sbin/dmidecode -s chassis-manufacturer`
# chassis_type=`/usr/sbin/dmidecode -s chassis-type`
# chassis_version=`/usr/sbin/dmidecode -s chassis-version`
# chassis_serial_number=`/usr/sbin/dmidecode -s chassis-serial-number`
# chassis_asset_tag=`/usr/sbin/dmidecode -s chassis-asset-tag`
# processor_family=`/usr/sbin/dmidecode -s processor-family | uniq`
# processor_manufacturer=`/usr/sbin/dmidecode -s processor-manufacturer | uniq`
# # processor_version=`/usr/sbin/dmidecode -s processor-version | uniq`
# processor_frequency=`/usr/sbin/dmidecode -s processor-frequency | uniq`

# processor_version=`cat /proc/cpuinfo | grep "model name" | uniq | cut -d: -f2 | xargs`

# echo
# echo 'bios_vendor                 : '$bios_vendor
# echo 'bios_version                : '$bios_version
# echo 'bios_release_date           : '$bios_release_date
# echo 'system_manufacturer         : '$system_manufacturer
# echo 'system_product_name         : '$system_product_name
# echo 'system_version              : '$system_version
# echo 'system_serial_number        : '$system_serial_number
# echo 'system_uuid                 : '$system_uuid
# echo 'baseboard_manufacturer      : '$baseboard_manufacturer
# echo 'baseboard_product_name      : '$baseboard_product_name
# echo 'baseboard_version           : '$baseboard_version
# echo 'baseboard_serial_number     : '$baseboard_serial_number
# echo 'baseboard_asset_tag         : '$baseboard_asset_tag
# echo 'chassis_manufacturer        : '$chassis_manufacturer
# echo 'chassis_type                : '$chassis_type
# echo 'chassis_version             : '$chassis_version
# echo 'chassis_serial_number       : '$chassis_serial_number
# echo 'chassis_asset_tag           : '$chassis_asset_tag
# echo 'processor_family            : '$processor_family
# echo 'processor_manufacturer      : '$processor_manufacturer
# echo 'processor_version           : '$processor_version
# echo 'processor_frequency         : '$processor_frequency
# echo

#
####################################################################################################

tns=whse
username=taggedmeta
userpwd=taggedmeta123

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

set feedback off

declare
begin
	merge into server_info t
	using (
		select	'$server_name' server_name,
			'$ip_address' ip_address,
			'$platform_version' platform_version,
			'$platform_release' platform_release,
			'$cpu_model' cpu_model,
			'$cpu_speed' cpu_speed,
			'$cpu_socket_count' cpu_socket_count,
			'$cpu_cores_per_socket' cpu_cores_per_socket,
			'$cpu_siblings' cpu_siblings,
			'$is_hyperthreaded' hyperthreading,
			'$cpu_cache_size' cpu_cache_size,
			'$total_ram' total_ram,
			'$total_ram_gb' total_ram_gb,
			'$huge_memory_pages' huge_memory_pages,
			'$huge_memory_size_gb' huge_memory_size_gb,
			'$db_edition' db_edition,
			'$db_version' db_version,
			'$cpu_licenses_used' cpu_licenses_used,
			'$standard_licenses_used' standard_licenses_used,
			'$oracle_licenses_being_used' oracle_licenses_used,
			'$data_volume_size' data_volume_size,
			'$log_volume_size' log_volume_size,
			'$ORACLE_SID' instance_name,
			'$instance_name_all' instance_name_all
		from	dual ) s
	on	( t.server_name = s.server_name )
	when matched then
		update
		set	ip_address = s.ip_address,
			platform_version = s.platform_version,
			platform_release = s.platform_release,
			cpu_model = s.cpu_model,
			cpu_speed = s.cpu_speed,
			cpu_socket_count = s.cpu_socket_count,
			cpu_cores_per_socket = s.cpu_cores_per_socket,
			cpu_siblings = s.cpu_siblings,
			hyperthreading = s.hyperthreading,
			cpu_cache_size = s.cpu_cache_size,
			total_ram = s.total_ram,
			total_ram_gb = s.total_ram_gb,
			huge_memory_pages = s.huge_memory_pages,
			huge_memory_size_gb = s.huge_memory_size_gb,
			db_edition = s.db_edition,
			db_version = s.db_version,
			cpu_licenses_used = s.cpu_licenses_used,
			standard_licenses_used = s.standard_licenses_used,
			oracle_licenses_used = s.oracle_licenses_used,
			data_volume_size = s.data_volume_size,
			log_volume_size = s.log_volume_size,
			instance_name = s.instance_name,
			instance_name_all = s.instance_name_all
	when not matched then insert(
			server_name, ip_address, platform_version,
			platform_release, cpu_model, cpu_speed, cpu_socket_count, cpu_cores_per_socket,
			cpu_siblings, hyperthreading, cpu_cache_size,
			total_ram, total_ram_gb, huge_memory_pages,
			huge_memory_size_gb, db_edition, db_version,
			cpu_licenses_used, standard_licenses_used, oracle_licenses_used,
			data_volume_size, log_volume_size, instance_name,
			instance_name_all )
		values(
			'$server_name', '$ip_address', '$platform_version',
			'$platform_release', '$cpu_model', '$cpu_speed', '$cpu_socket_count', '$cpu_cores_per_socket',
			'$cpu_siblings', '$is_hyperthreaded', '$cpu_cache_size',
			'$total_ram', '$total_ram_gb', '$huge_memory_pages',
			'$huge_memory_size_gb', '$db_edition', '$db_version',
			'$cpu_licenses_used', '$standard_licenses_used', '$oracle_licenses_being_used',
			'$data_volume_size', '$log_volume_size', '$ORACLE_SID',
			'$instance_name_all' );
	commit;

end;
/

exit;
EOF
