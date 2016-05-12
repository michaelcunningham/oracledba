#!/bin/bash

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <event_name> <event_description> <script_name $0> [ORACLE_SID] [host_name] [status]"
  echo
  echo "   Example: $0 \"ADD_DATA_FILE\" \"Added datafile\" \"$0\" orcl ora27 SUCCESS"
  echo
  exit
fi

export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$4
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

tns=whse
username=taggedmeta
userpwd=taggedmeta123

event_name=$1
event_description=$2
script_name=$3
instance_name=$4
host_name=$5
status=$6

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns
set feedback off

insert into db_event(
	event_name, event_description, status,
	host_name, instance_name, script_name )
values(
	'$event_name', '$event_description', '$status',
	'$host_name', '$instance_name', '$script_name' );

commit;

exit;
EOF
