#! /bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <target_server>"
  echo
  echo "   Example: $0 orcl sora99"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

target_server=$2

mkdir -p /u02/oradata/${ORACLE_SID}/arch

sqlplus -s /nolog << EOF
connect / as sysdba
create pfile from spfile;
exit;
EOF

cp -p $ORACLE_HOME/dbs/*${ORACLE_SID}* /mnt/db_transfer/$ORACLE_SID/dbs

scp /u01/app/oracle/admin/common_scripts/* oracle@$target_server:/u01/app/oracle/admin/common_scripts

echo
echo "	##############################################################################################################"
echo
echo "	Modify init file at to reflect file system locations for control files"
echo "		/mnt/db_transfer/$ORACLE_SID/dbs/init${ORACLE_SID}.ora"
echo
echo "	*.control_files='/u02/oradata/$ORACLE_SID/ctl/control01.ctl','/u02/oradata/$ORACLE_SID/ctl/control02.ctl'"
echo
echo "	##############################################################################################################"
echo
