#!/bin/sh

OLD_UMASK=`umask`
umask 0027

mkdir -p /u01/app/oracle/admin/db_name_template/adump
mkdir -p /u01/app/oracle/admin/db_name_template/dpdump
mkdir -p /u01/app/oracle/admin/db_name_template/pfile
# mkdir -p /u01/app/oracle/audit/db_name_template
mkdir -p /u01/app/oracle/cfgtoollogs/dbca/db_name_template
mkdir -p /u01/app/oracle/db_name_templatefast_recovery_area
umask ${OLD_UMASK}
PERL5LIB=$ORACLE_HOME/rdbms/admin:$PERL5LIB; export PERL5LIB

export ORACLE_SID=db_name_template
export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1

PATH=$ORACLE_HOME/bin:$PATH; export PATH

# echo You should Add this entry in the /etc/oratab: db_name_template:/u01/app/oracle/product/12.1.0/dbhome_1:Y

cp -p /etc/oratab /tmp/oratab.1
cat /tmp/oratab.1 | sed '/^db_name_template/d' > /etc/oratab
echo "db_name_template:/u01/app/oracle/product/12.1.0/dbhome_1:Y:" >> /etc/oratab

/u01/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus /nolog @/u01/app/oracle/admin/db_name_template/scripts/db_name_template.sql

mkdir -p /u01/app/oracle/admin/db_name_template/scripts/log
mv /u01/app/oracle/admin/db_name_template/scripts/*.log /u01/app/oracle/admin/db_name_template/scripts/log
