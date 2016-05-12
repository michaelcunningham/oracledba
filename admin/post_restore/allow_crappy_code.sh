#!/bin/sh

export ORACLE_SID=tdcdv4

. /dba/admin/dba.lib

sqlplus -s /nolog << EOF
connect / as sysdba

alter system set undo_retention=400;
alter database datafile '/${ORACLE_SID}/oradata/undotbs01.dbf' autoextend on next 1G maxsize unlimited;
alter database datafile '/${ORACLE_SID}/oradata/undotbs02.dbf' autoextend on next 1G maxsize unlimited;
alter database tempfile '/${ORACLE_SID}/oradata/temp01.dbf' autoextend on next 1G maxsize unlimited;
exit;
EOF

rsh npnetapp104 vol size $ORACLE_SID 400g
