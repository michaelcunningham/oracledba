#!/bin/sh

OLD_UMASK=`umask`
umask 0027
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oracle/admin/IMDB/adump
mkdir -p /u01/app/oracle/admin/IMDB/dpdump
mkdir -p /u01/app/oracle/admin/IMDB/pfile
mkdir -p /u01/app/oracle/audit
mkdir -p /u01/app/oracle/cfgtoollogs/dbca/IMDB
umask ${OLD_UMASK}
PERL5LIB=$ORACLE_HOME/rdbms/admin:$PERL5LIB; export PERL5LIB
ORACLE_SID=IMDB; export ORACLE_SID
PATH=$ORACLE_HOME/bin:$PATH; export PATH
echo You should Add this entry in the /etc/oratab: IMDB:/u01/app/oracle/product/12.1.0.2/dbhome_1:Y
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus /nolog @/u01/app/oracle/admin/IMDB/scripts/IMDB.sql
