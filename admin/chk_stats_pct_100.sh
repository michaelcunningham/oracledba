#!/bin/sh

#export ORAENV_ASK=NO

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  exit
fi

export ORACLE_SID=$1
. /usr/local/bin/oraenv

. /dba/admin/dba.lib

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_file=${adhoc_dir}/log/${ORACLE_SID}_chk_stats_pct_100_${log_date}.txt
email_body_file=${adhoc_dir}/log/${ORACLE_SID}_chk_stats_pct_100_${log_date}.email

sqlplus -s "/ as sysdba" << EOF > $log_file
set serveroutput on
set tab off
set linesize 200
set pagesize 200
set term off
set feedback off

column owner           format   a20          heading 'Owner'
column object_type     format   a10          heading 'Obj Type'
column object_name     format   a30          heading 'Obj Name'
column last_analyzed   format   date         heading 'Last Analyzed'
column sample_size     format   999,999,999  heading 'Sample Size'
column num_rows        format   999,999,999  heading 'Num Rows'

alter session set nls_date_format='MM/dd/yyyy @ hh24:mi';

select	owner, object_type, object_name,
	last_analyzed, sample_size, num_rows
from	(
	select	owner, 'TABLE' object_type, table_name object_name,
		last_analyzed, sample_size, num_rows
	from	dba_tables
	where	num_rows <> sample_size
	union all
	select	owner, 'INDEX' object_type, index_name object_name,
		last_analyzed, sample_size, num_rows
	from	dba_indexes
	where	num_rows <> sample_size
	)
where	( owner in( 'NOVAPRD', 'VISTAPRD', 'DWOWNER', 'DMPROD',
		'STARTEAM', 'TDCGLOBAL',
		'INRULEREPOSITORY', 'APPLOG'  )
	or owner like 'SECURITY%' )
order by object_type desc, object_name;

exit;
EOF

#echo '' >> $log_file
#echo '' >> $log_file
#echo 'This report created by : '$0' '$* >> $log_file

if [ -s $log_file ]
then
	echo "The information below shows objects where statistics did not use estimate_percent => 100%." > $email_body_file
	echo "" >> $email_body_file

	cat $log_file >> $email_body_file

	echo "" >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file
	echo 'This report created by : '$0 >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file

	mail_subj=`echo $ORACLE_SID | awk '{print toupper($0)}'`" - Statistics with incorrect estimate_percent"
	mutt -s "$mail_subj" mcunningham@thedoctors.com < $email_body_file
	mutt -s "$mail_subj" swahby@thedoctors.com < $email_body_file
fi

