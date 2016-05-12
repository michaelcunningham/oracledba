#!/bin/sh

tns=//npdb520.tdc.internal:1529/apex.tdc.internal
username=lmon
userpwd=lmon

echo
echo ...................... running stats

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

begin 
	dbms_stats.gather_schema_stats( '$2', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size );
end; 
/ 

exit;
EOF

