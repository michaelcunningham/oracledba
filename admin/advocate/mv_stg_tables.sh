#!/bin/sh

advocate_dir=/dba/admin/advocate

####################################################################################################
#
# First thing is to run the export on the source ORACLE_SID
#
# /dba/admin/advocate/exp_advocate_work_tables.sh tdcdv4
#
####################################################################################################

/dba/admin/advocate/stg_tables_disable_fk.sh $ORACLE_SID

/dba/admin/advocate/stg_tables_disable_all_triggers.sh $ORACLE_SID

/dba/admin/advocate/stg_tables_truncate.sh $ORACLE_SID

/dba/admin/advocate/imp_advocate_work_tables.sh <source database> $ORACLE_SID

/dba/admin/advocate/stg_tables_enable_all_triggers.sh $ORACLE_SID

/dba/admin/advocate/stg_tables_enable_fk.sh $ORACLE_SID

/dba/admin/advocate/stg_tables_set_sequences.sh $ORACLE_SID

/dba/admin/gather_schema_stats_100.sh $ORACLE_SID novaprd
