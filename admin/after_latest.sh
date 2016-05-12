#!/bin/sh

/oracle/app/oracle/admin/tdccv1/adhoc/conv/fix_bitmap_indexes.sh
#/oracle/app/oracle/admin/tdccv1/adhoc/conv/new_indexes.sh


/oracle/app/oracle/admin/tdccv1/adhoc/conv/mk_undo_bigger.sh

/dba/nova4/stats_import_conv_stats_table.sh tdccv1 novaprd stats_latest
/dba/nova4/stats_import_schema_stats.sh tdccv1 novaprd stats_latest

/dba/create/create_spotlight_tbs.sh tdccv1

rsh npnetapp104 vol size tdccv1 500g
