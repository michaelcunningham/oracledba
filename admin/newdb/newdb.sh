#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1

scripts_dir=/u01/app/oracle/admin/${ORACLE_SID}/scripts
mkdir -p $scripts_dir

# Make the init.ora file from the template
sed "s/db_name_template/${ORACLE_SID}/g" init_template.ora > $scripts_dir/init.ora
sed "s/db_name_template/${ORACLE_SID}/g" newdb_template.sh > $scripts_dir/${ORACLE_SID}.sh
sed "s/db_name_template/${ORACLE_SID}/g" newdb_template.sql > $scripts_dir/${ORACLE_SID}.sql
sed "s/db_name_template/${ORACLE_SID}/g" remove_template.sh > $scripts_dir/remove_${ORACLE_SID}.sh
sed "s/db_name_template/${ORACLE_SID}/g" lockAccount_template.sql > $scripts_dir/lockAccount.sql
sed "s/db_name_template/${ORACLE_SID}/g" CreateDB_template.sql > $scripts_dir/CreateDB.sql
sed "s/db_name_template/${ORACLE_SID}/g" CreateDBCatalog_template.sql > $scripts_dir/CreateDBCatalog.sql
sed "s/db_name_template/${ORACLE_SID}/g" CreateDBFiles_template.sql > $scripts_dir/CreateDBFiles.sql
sed "s/db_name_template/${ORACLE_SID}/g" postDBCreation_template.sql > $scripts_dir/postDBCreation.sql
chmod u+x $scripts_dir/${ORACLE_SID}.sh
chmod u+x $scripts_dir/remove_${ORACLE_SID}.sh

echo
echo "	The next step is to do the following"
echo "	cd /u01/app/oracle/admin/${ORACLE_SID}/scripts"
echo "	./${ORACLE_SID}.sh"
echo
