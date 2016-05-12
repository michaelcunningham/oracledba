#!/bin/sh

unset SQLPATH
export ORACLE_SID=fmd
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

log_date=`date +%Y%m%d_%H%M%p`

username=tag
userpwd=zx6j1bft

sqlplus -s /nolog  << EOF
connect sys/Admin_123@//129.144.33.60:1521/orcl.a343916.oraclecloud.internal as sysdba

@drop_tag_user
@create_tag_user

exit;
EOF

exit

/dba/create/create_external_dir.sh fmd
/dba/projects/oracle_to_postgres/MMDB01/impdp_mmdb01_p0.sh

sqlplus -s /nolog  << EOF
connect $username/$userpwd

@build_views.sql
@build_plsql.sql

exit;
EOF
