#!/bin/sh

export ORACLE_SID=db_name_template
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
sqlplus /nolog << EOF
connect / as sysdba
shutdown abort
exit;
EOF

sleep 5

rm -rf /u01/app/oracle/admin/db_name_template/scripts/log
rm -rf /u01/app/oracle/admin/db_name_template/adump
rm -rf /u01/app/oracle/admin/db_name_template/dpdump
rm -rf /u01/app/oracle/admin/db_name_template/pfile
rm -rf /u01/app/oracle/audit/db_name_template
rm -rf /u01/app/oracle/cfgtoollogs/dbca/db_name_template
rm -rf /u01/app/oracle/db_name_templatefast_recovery_area

export ORACLE_SID=+ASM
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

asmcmd rm -r data/db_name_templatea/controlfile/*
asmcmd rm -r data/db_name_templatea/datafile/*
asmcmd rm -r data/db_name_templatea/onlinelog/*
asmcmd rm -r data/db_name_templatea/tempfile/*
asmcmd rm -r log/db_name_templatea/controlfile/*
asmcmd rm -r log/db_name_templatea/onlinelog/*

rm /u01/app/oracle/product/12.1.0/dbhome_1/dbs/initdb_name_template.ora
rm /u01/app/oracle/product/12.1.0/dbhome_1/dbs/orapwdb_name_template
rm -rf /u01/app/oracle/diag/rdbms/db_name_templatea
rm -rf /u01/app/oracle/cfgtoollogs/dbca/db_name_template

cp -p /etc/oratab /tmp/oratab.1
cat /tmp/oratab.1 | sed '/^db_name_template/d' > /etc/oratab
