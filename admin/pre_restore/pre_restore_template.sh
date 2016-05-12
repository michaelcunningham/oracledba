#!/bin/sh

export ORACLE_SID=ORACLE_SID

adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
admin_dir=/dba/admin

# SECURITY
/dba/admin/pre_restore/security_save_process.sh $ORACLE_SID

