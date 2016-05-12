#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage: $0 <ORACLE_SID_FOR_LISTENER>"
  echo
  echo "        Example: $0 novadev"
  echo
  exit 2
else
  export ORACLE_SID_FOR_LISTENER=$1
fi

server_name=`hostname | awk -F . '{print $1}'`
tns=//npdb520.tdc.internal:1529/apex.tdc.internal
username=lmon
userpwd=lmon

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/listener_log/log/${ORACLE_SID}_listener_log.log

echo ...................... importing listener log data

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

set term off
set feedback off

drop table listener_log_file;
create table listener_log_file( log_text varchar2(500) )
organization external (
	type oracle_loader
	default directory netlog
	access parameters (
		records delimited by newline
		nobadfile
		nodiscardfile
		nologfile
		)
	location( 'l_${ORACLE_SID_FOR_LISTENER}.log.5' )
	)
reject limit unlimited;

merge into listener_log t
using (
	select	distinct '$server_name' server_name, '$ORACLE_SID_FOR_LISTENER' instance_name, log_text
	from	listener_log_file
	where	log_text not like '%service_update%'
	and	log_text not like '%log_directory%'
	and	log_text not like '%trc_directory%'
	and	log_text not like 'Copyright%'
	and	log_text not like 'Listen%'
	and	log_text not like 'No longer%' ) s
on ( s.server_name = t.server_name and s.instance_name = t.instance_name and s.log_text = t.log_text )
when not matched then insert( t.server_name, t.instance_name, t.log_text )
values( s.server_name, s.instance_name, s.log_text );

commit;

-- #############################################################################################

alter table listener_log_file location( 'l_${ORACLE_SID_FOR_LISTENER}.log.4' );

merge into listener_log t
using (
        select  distinct '$server_name' server_name, '$ORACLE_SID_FOR_LISTENER' instance_name, log_text
	from	listener_log_file
	where	log_text not like '%service_update%'
	and	log_text not like '%log_directory%'
	and	log_text not like '%trc_directory%'
	and	log_text not like 'Copyright%'
	and	log_text not like 'Listen%'
	and	log_text not like 'No longer%' ) s
on ( s.server_name = t.server_name and s.instance_name = t.instance_name and s.log_text = t.log_text )
when not matched then insert( t.server_name, t.instance_name, t.log_text )
values( s.server_name, s.instance_name, s.log_text );

commit;

-- #############################################################################################

alter table listener_log_file location( 'l_${ORACLE_SID_FOR_LISTENER}.log.3' );

merge into listener_log t
using (
        select  distinct '$server_name' server_name, '$ORACLE_SID_FOR_LISTENER' instance_name, log_text
	from	listener_log_file
	where	log_text not like '%service_update%'
	and	log_text not like '%log_directory%'
	and	log_text not like '%trc_directory%'
	and	log_text not like 'Copyright%'
	and	log_text not like 'Listen%'
	and	log_text not like 'No longer%' ) s
on ( s.server_name = t.server_name and s.instance_name = t.instance_name and s.log_text = t.log_text )
when not matched then insert( t.server_name, t.instance_name, t.log_text )
values( s.server_name, s.instance_name, s.log_text );

commit;

-- #############################################################################################

alter table listener_log_file location( 'l_${ORACLE_SID_FOR_LISTENER}.log.2' );

merge into listener_log t
using (
        select  distinct '$server_name' server_name, '$ORACLE_SID_FOR_LISTENER' instance_name, log_text
	from	listener_log_file
	where	log_text not like '%service_update%'
	and	log_text not like '%log_directory%'
	and	log_text not like '%trc_directory%'
	and	log_text not like 'Copyright%'
	and	log_text not like 'Listen%'
	and	log_text not like 'No longer%' ) s
on ( s.server_name = t.server_name and s.instance_name = t.instance_name and s.log_text = t.log_text )
when not matched then insert( t.server_name, t.instance_name, t.log_text )
values( s.server_name, s.instance_name, s.log_text );

commit;

-- #############################################################################################

alter table listener_log_file location( 'l_${ORACLE_SID_FOR_LISTENER}.log.1' );

merge into listener_log t
using (
        select  distinct '$server_name' server_name, '$ORACLE_SID_FOR_LISTENER' instance_name, log_text
	from	listener_log_file
	where	log_text not like '%service_update%'
	and	log_text not like '%log_directory%'
	and	log_text not like '%trc_directory%'
	and	log_text not like 'Copyright%'
	and	log_text not like 'Listen%'
	and	log_text not like 'No longer%' ) s
on ( s.server_name = t.server_name and s.instance_name = t.instance_name and s.log_text = t.log_text )
when not matched then insert( t.server_name, t.instance_name, t.log_text )
values( s.server_name, s.instance_name, s.log_text );

commit;

-- #############################################################################################


alter table listener_log_file location( 'l_${ORACLE_SID_FOR_LISTENER}.log' );

merge into listener_log t
using (
        select  distinct '$server_name' server_name, '$ORACLE_SID_FOR_LISTENER' instance_name, log_text
	from	listener_log_file
	where	log_text not like '%service_update%'
	and	log_text not like '%log_directory%'
	and	log_text not like '%trc_directory%'
	and	log_text not like 'Copyright%'
	and	log_text not like 'Listen%'
	and	log_text not like 'No longer%' ) s
on ( s.server_name = t.server_name and s.instance_name = t.instance_name and s.log_text = t.log_text )
when not matched then insert( t.server_name, t.instance_name, t.log_text )
values( s.server_name, s.instance_name, s.log_text );

commit;

exit;
EOF

