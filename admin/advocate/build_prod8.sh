#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

advocate_dir=/dba/admin/advocate

$advocate_dir/create/create_advocate_tbs.sh $ORACLE_SID
$advocate_dir/create/create_prod8_user_user.sh $ORACLE_SID
$advocate_dir/create/create_advocate_dir_directory.sh $ORACLE_SID
$advocate_dir/export/impdp_opco_schema.sh opco $ORACLE_SID prod8_user
$advocate_dir/create/privs_prod8.sh $ORACLE_SID
# $advocate_dir/create/create_prod8_views.sh $ORACLE_SID
