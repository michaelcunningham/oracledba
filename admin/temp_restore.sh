rsync -a /dba/admin_backup/npdb520_${ORACLE_SID}_Thu/ /oracle/app/oracle/admin/${ORACLE_SID}/
rm -r /oracle/app/oracle/admin/${ORACLE_SID}/dbs
mkdir /oracle/app/oracle/admin/${ORACLE_SID}/adump
mkdir /oracle/app/oracle/admin/${ORACLE_SID}/bdump
mkdir /oracle/app/oracle/admin/${ORACLE_SID}/udump
mkdir /oracle/app/oracle/admin/${ORACLE_SID}/ctl
mkdir /oracle/app/oracle/admin/${ORACLE_SID}/redo
mv /oracle/app/oracle/admin/${ORACLE_SID}/ctl/ctl1${ORACLE_SID}.ctl /oracle/app/oracle/admin/${ORACLE_SID}/ctl/ctl1${ORACLE_SID}.ctl.bk
cp /${ORACLE_SID}/ctl/ctl2${ORACLE_SID}.ctl /oracle/app/oracle/admin/${ORACLE_SID}/ctl/ctl1${ORACLE_SID}.ctl

ln -s /oracle/app/oracle/admin/${ORACLE_SID}/pfile/init${ORACLE_SID}.ora \
/oracle/app/oracle/product/10.2.0/db_1/dbs/init${ORACLE_SID}.ora

/oracle/app/oracle/product/10.2.0/db_1/bin/orapwd \
file=/oracle/app/oracle/product/10.2.0/db_1/dbs/orapw${ORACLE_SID} password=jedi65 force=y

cp /redologs/${ORACLE_SID}/redo_${ORACLE_SID}_01a.redo /oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_01b.redo
cp /redologs/${ORACLE_SID}/redo_${ORACLE_SID}_02a.redo /oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_02b.redo
cp /redologs/${ORACLE_SID}/redo_${ORACLE_SID}_03a.redo /oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_03b.redo
cp /redologs/${ORACLE_SID}/redo_${ORACLE_SID}_04a.redo /oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_04b.redo
cp /redologs/${ORACLE_SID}/redo_${ORACLE_SID}_05a.redo /oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_05b.redo

sqlplus /nolog << EOF
connect / as sysdba
create spfile from pfile;
startup
EOF


