#! /bin/sh

# scripts_dir=/mnt/dba/scripts
sql_file=/mnt/dba/work/`hostname -s`_asm_migration.sql

# echo $sql_file

export ORACLE_SID=+ASM
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

sqlplus -s "/ as sysasm" << EOF > $sql_file
set feedback off
set linesize 2000
set serveroutput on
@/mnt/dba/scripts/asm_make_migration_code.sql
exit;
EOF

echo
echo "	The name of the migration script is:"
echo "	"$sql_file
echo
echo "	Login to ASM to run the script"
echo "	Monitor the ASM migration using: /mnt/dba/scripts/asm_operations.sql"
echo
