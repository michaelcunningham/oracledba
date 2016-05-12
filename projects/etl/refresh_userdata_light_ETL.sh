#!/bin/sh

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=ETL
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

username=tag
userpwd=zx6j1bft
tns=ETL

sqlplus /nolog << EOF
connect $username/$userpwd@$tns

exec userdata_light_pkg.refresh_userdata_light( 'TDB', 'PDB' );

exit;
EOF
