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

$advocate_dir/create/create_imageright_tbs.sh $ORACLE_SID
$advocate_dir/create/create_imageright_user_user.sh $ORACLE_SID
$advocate_dir/export/impdp_opco_schema.sh opco $ORACLE_SID imageright_user
$advocate_dir/create/privs_imageright.sh $ORACLE_SID
# $advocate_dir/create/create_imageright_views.sh $ORACLE_SID
