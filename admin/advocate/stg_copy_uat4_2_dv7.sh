#!/bin/sh

export ORACLE_SID=tdcdv7
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

advocate_dir=/dba/admin/advocate

####################################################################################################
#
# First thing is to run the export on the source ORACLE_SID
#
# /dba/admin/advocate/exp_advocate_work_tables.sh tdcuat4
#
####################################################################################################

/dba/admin/advocate/stg_tables_disable_fk.sh tdcdv7

/dba/admin/advocate/stg_tables_disable_all_triggers.sh tdcdv7

/dba/admin/advocate/stg_tables_truncate.sh tdcdv7

/dba/admin/advocate/imp_advocate_work_tables.sh tdcuat4 tdcdv7

/dba/admin/advocate/stg_tables_enable_all_triggers.sh tdcdv7

/dba/admin/advocate/stg_tables_enable_fk.sh tdcdv7

/dba/admin/advocate/stg_tables_set_sequences.sh tdcdv7

/dba/admin/gather_schema_stats_100.sh tdcdv7 novaprd

dp 5/Copy staging tables from UAT4 to DV7 complete
