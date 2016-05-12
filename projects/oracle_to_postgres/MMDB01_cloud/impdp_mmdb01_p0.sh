#!/bin/sh

unset SQLPATH
export ORACLE_SID=fmd
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

log_date=`date +%Y%m%d_%H%M%p`

username=tag
userpwd=zx6j1bft

imp_file=SMMDB01_tag_p0_tables_20160510_1851PM.dmp
log_file=SMMDB01_tag_p0_tables_20160510_1851PM.imp

impdp $username/$userpwd directory=external_dir \
tables=APP_MEETME_MATCHES_P0, \
APP_MEETME_MATCHES_SUGG_P0, \
APP_MEETME_RATINGS_P0, \
APP_MEETME_RESP2_P0, \
APP_MEETME_RESP_P0, \
APP_MEETME_SPOTLIGHT_P0, \
APP_MEETME_SUGGESTIONS_P0, \
APP_MEETME_T0_P0, \
APP_MEETME_T1_P0, \
APP_MEETME_T2_P0, \
APP_MEETME_T3_P0, \
APP_MEETME_T4_P0, \
APP_MEETME_T5_P0, \
PDB_LAYOUT, \
TTABLE_AUDIT \
dumpfile=${imp_file} logfile=${log_file}

