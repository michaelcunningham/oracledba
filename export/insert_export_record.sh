#!/bin/sh

#tns=db10
#username=tdce
#pwd=tdce
#tns=//10.1.11.48:1523/apex.tdccorp48.tdc.internal
tns=npdb530.tdc.internal:1539/apex.tdc.internal
username=tdce
pwd=tdce

node=`uname -n`

sqlplus $username/$pwd@$tns << EOF
insert into export_log( machine, instance, username, dmp_file_name )
values( '$node', '$1', '$2', '$3' );
commit;

exit;
EOF

