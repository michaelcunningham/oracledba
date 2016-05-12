#! /bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <from_ORACLE_SID> <to_ORACLE_SID> <tablespace_name>"
  echo
  echo "   Example: $0 TDB00 TDB01 P0TBS"
  echo
  exit
fi

to_ORACLE_SID=$2
tablespace_name=$3

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

echo
echo "	Exporting tablespace $tablespace_name for transport..."
echo

exp userid=\"/ as sysdba\" transport_tablespace=y \
tablespaces=$tablespace_name \
statistics=none constraints=y grants=y file=/mnt/dba/adhoc/rac/${ORACLE_SID}_transport.dmp
