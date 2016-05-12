#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <sv pair suffix>"
  echo
  echo "   Example: $0 svdev dv4"
  echo
  exit
fi

sv_pair=$2
exp_file=${sv_pair}.dmp
log_file=${sv_pair}.log
exp_file_full=/u01/export/dmp/${exp_file}
log_file_full=/u01/export/log/${log_file}

expdp system/jedi65 schemas=ora\$${sv_pair},vista${sv_pair},vista_user${sv_pair} \
directory=data_exports dumpfile=${exp_file} logfile=${log_file}

rm ${exp_file}.Z
compress ${exp_file}

