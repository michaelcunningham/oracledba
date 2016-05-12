#!/bin/sh

export PATH=/usr/local/bin:$PATH
export ORACLE_SID=+ASM
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

server_name=`hostname -s`

# Make a | delimited string
asm_info=`srvctl config asm | tr '\n' '|'`
asm_home=`echo $asm_info | cut -d'|' -f1 | cut -d':' -f2`
asm_listener=`echo $asm_info | cut -d'|' -f2 | cut -d':' -f2`
asm_pwfile=`echo $asm_info | cut -d'|' -f3 | cut -d':' -f2`
asm_spfile=`echo $asm_info | cut -d'|' -f4 | cut -d':' -f2`
echo $asm_info | cut -d'|' -f5 | cut -d':' -f2
asm_diskgroup=`echo $asm_info | cut -d'|' -f5 | cut -d':' -f2`

# chomp all the variables
asm_info=`echo $asm_info`
asm_home=`echo $asm_home`
asm_listener=`echo $asm_listener`
asm_pwfile=`echo $asm_pwfile`
asm_spfile=`echo $asm_spfile`
#asm_diskgroup=`echo $asm_diskgroup`

echo $asm_info
echo "asm_home        = "$asm_home
echo "asm_pwfile      = "$asm_pwfile
echo "asm_listener    = "$asm_listener
echo "asm_spfile      = "$asm_spfile
echo "asm_diskgroup   = "$asm_diskgroup

exit

####################################################################################################
#
# Create the database link for the DMMASTER database.
#
####################################################################################################
db_cpu=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba

select round( value / 1000000 ) db_cpu from v\\$sys_time_model where stat_name = 'DB CPU';

exit;
EOF`

db_cpu=`echo $db_cpu`

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=dmmaster
userpwd=dm7master

####################################################################################################
#
# Record the CPU Time.
#
server_name=`hostname -s`

# Make a | delimited string
asm_info=`srvctl config asm | tr '\n' '|'`
asm_home=`echo $asm_info | cut -d'|' -f1 | cut -d':' -f2`
asm_listener=`echo $asm_info | cut -d'|' -f2 | cut -d':' -f2`
asm_pwfile=`echo $asm_info | cut -d'|' -f3 | cut -d':' -f2`
asm_spfile=`echo $asm_info | cut -d'|' -f4 | cut -d':' -f2`
asm_diskgroup=`echo $asm_info | cut -d'|' -f5 | cut -d':' -f2`

####################################################################################################
sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

declare
begin
	merge into has_asm_info t
	using (
		select	'$server_name' server_name,
			'$asm_home' home, '$asm_listener' listener,
			'$server_name' server_name, '$server_name' server_name, '$server_name' server_name
		from	dual ) s
	on	( t.server_name = s.server_name and t.collection_date = s.collection_date )
	when matched then
		update
		set	cpu_seconds = s.cpu_seconds
	when not matched then insert(
			instance_name, collection_date, cpu_seconds )
		values(
			'$instance_name', s.collection_date, s.cpu_seconds );
	commit;

end;
/

exit;
EOF
