#! /bin/sh

unset SQLPATH
export ORACLE_SID=WHSE
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

arch_file=$1
# echo $arch_file

is_applied=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select applied from v\\$archived_log where name = '$arch_file';
exit;
EOF`

is_applied=`echo $is_applied`
# echo $is_applied

export ORACLE_SID=+ASM
. /usr/local/bin/oraenv -s

if [ "$is_applied" = "YES" ]
then
  echo $arch_file
  asmcmd rm $arch_file
fi
