#!/bin/sh

unset SQLPATH
export ORACLE_SID=DEVPDB01
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

log_date=`date +%Y%m%d_%H%M%p`

username=tag
userpwd=zx6j1bft

exp_file=${ORACLE_SID}_${username}_dp_${log_date}.dmp
log_file=${ORACLE_SID}_${username}_dp_${log_date}.log

expdp $username/$userpwd directory=external_dir tables=ZIP_GEOGRAPHY_224 dumpfile=${exp_file} logfile=${log_file}

