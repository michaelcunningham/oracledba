#!/bin/sh

# Get an ORACLE_SID (any one) so we can set the environment
ORACLE_SID=`ps -ef | grep pmon | grep -v "grep pmon" | cut -f3 -d_ | head -1`

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

log_date=`date +%Y%m%d`
rpt_dir=/dba/admin/weekly_report
log_file=/dba/admin/weekly_report/log/weekly_report_${log_date}.txt
email_body_file=/dba/admin/weekly_report/log/weekly_report_${log_date}.email

> $log_file
> $email_body_file


echo 'DATABASE FILERS' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/database_filers.sh >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'VOLUME USAGE STATS' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/oracle.sh >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'STALE STATISTICS' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/stale_statistics.sh tdcprd novaprd >> $log_file
$rpt_dir/stale_statistics.sh tdcprd vistaprd >> $log_file
$rpt_dir/stale_statistics.sh dwprd dwowner >> $log_file
$rpt_dir/stale_statistics.sh itprd applog >> $log_file
$rpt_dir/stale_statistics.sh itprd boauditxi4 >> $log_file
$rpt_dir/stale_statistics.sh itprd bommxi4 >> $log_file
$rpt_dir/stale_statistics.sh itprd borepxi4 >> $log_file
$rpt_dir/stale_statistics.sh itprd ignite43 >> $log_file
$rpt_dir/stale_statistics.sh itprd inforep >> $log_file
$rpt_dir/stale_statistics.sh itprd inforep_srv >> $log_file
$rpt_dir/stale_statistics.sh itprd tidal >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'DBMS_JOBS' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/dbms_jobs.sh tdcprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/dbms_jobs.sh dwprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/dbms_jobs.sh itprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'DATABASE LINKS' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/db_links.sh tdcprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/db_links.sh dwprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/db_links.sh itprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'TABLESPACE REPORT' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/tbs.sh tdcprd >> $log_file
$rpt_dir/tbs.sh dwprd >> $log_file
$rpt_dir/tbs.sh itprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'ROWDEPENDENCIES REPORT' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/row_dependencies.sh tdcprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'TRIGGER REPORT' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/triggers.sh tdcprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/triggers.sh dwprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/triggers.sh itprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'CONSTRAINT REPORT' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/constraints.sh tdcprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/constraints.sh dwprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/constraints.sh itprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'SEQUENCES REPORT' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/sequences.sh tdcprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'TRIGGER REPORT' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/triggers.sh tdcprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/triggers.sh dwprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/triggers.sh itprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file

echo 'SECURITY AUDIT REPORT' >> $log_file
echo '________________________________________________________________________________________________________________________' >> $log_file
echo '' >> $log_file
$rpt_dir/security_audit.sh tdcprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/security_audit.sh dwprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
$rpt_dir/security_audit.sh itprd >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file
echo '' >> $log_file


echo "The attached file includes a list of items checked in production databases on a weekly basis." > $email_body_file
echo "" >> $email_body_file
echo "" >> $email_body_file
echo "################################################################################" >> $email_body_file
echo "" >> $email_body_file
echo 'This report created by : '$0 >> $email_body_file
echo "" >> $email_body_file
echo "################################################################################" >> $email_body_file
echo "" >> $email_body_file

email_group="mcunningham@thedoctors.com, swahby@thedoctors.comm"
mail_subj="DBA Weekly Report"

mutt -s "$mail_subj" `cat /dba/admin/dba_team` -a $log_file < $email_body_file
