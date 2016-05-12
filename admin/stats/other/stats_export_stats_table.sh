#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <tns> <username> <filename>"
  echo
  echo "   Example: $0 tdccv1 novaprd stats_uat4_20100715"
  echo
  exit
fi

. /dba/admin/dba.lib

export ORACLE_SID=$1
export username=$2
export filename=$3

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=`get_tns_from_orasid $ORACLE_SID`
userpwd=`get_user_pwd $tns $username`

exp $username/$userpwd file=/dba/nova4/dmp/$filename.dmp log=/dba/nova4/dmp/${filename}_exp.log tables=stats_history statistics=none
