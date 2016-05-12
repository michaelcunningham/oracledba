#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <username>"
  echo
  echo "   Example: $0 IMDB01 tag"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

. /mnt/dba/admin/dba.lib

ORACLE_SID_lower=`echo $1 | tr '[A-Z]' '[a-z]'`
username=$2
userpwd=`get_user_pwd $ORACLE_SID $username`

echo "ORACLE_SID           = "$ORACLE_SID
echo "ORACLE_SID_lower     = "$ORACLE_SID_lower
echo "username             = "$username
echo "userpwd              = "$userpwd
echo "syspwd               = "`get_sys_pwd $ORACLE_SID`
