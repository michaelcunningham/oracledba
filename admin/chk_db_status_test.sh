#! /bin/ksh

ORACLE_SID=fmd

/dba/admin/chk_db_status.sh $ORACLE_SID
result=$?
exit $result

