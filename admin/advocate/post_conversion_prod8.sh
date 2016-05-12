#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
username=prod8_user
userpwd=`get_user_pwd $tns $username`

log_file=/dba/admin/advocate/log/post_conversion_prod8_${ORACLE_SID}.log

if [ "$userpwd" = "" ]
then
  echo
  echo "   The user \"$username\" was not found in the oraid file."
  echo
  exit
fi

sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd

create unique index account_pk on account
	( policy_number, policy_date_time )
tablespace advocate_data;

alter table account add (
	constraint account_pk primary key( policy_number, policy_date_time )
	using index account_pk );


begin
	for r in(
		select	'delete from premium_detail where rowid = ''' || row_id || '''' as sql_text
		from	(
			select	policy_number, policy_date_time, premium_lob, sequence_number, count(*), max(rowid) row_id
			from	premium_detail
			group by policy_number, policy_date_time, premium_lob, sequence_number
			having count(*) > 1
			) )
	loop
		execute immediate r.sql_text;
	end loop;
	commit;
end;
/

create unique index premium_detail_idx on premium_detail
	( policy_number, policy_date_time, premium_lob, sequence_number, term_seq )
tablespace advocate_data;


create unique index premium_detail_pk on premium_detail
	( policy_number, policy_date_time, premium_lob, sequence_number )
tablespace advocate_data;


alter table premium_detail add (
	constraint premium_detail_pk primary key
	( policy_number, policy_date_time, premium_lob, sequence_number )
	using index premium_detail_pk );


create unique index accttran_pk on accttran
	( policy_number, account_set, date_time, activity_type )
tablespace advocate_data;

alter table accttran add (
	constraint accttran_pk primary key
	( policy_number, account_set, date_time, activity_type )
	using index accttran_pk );


begin
	for r in(
		select	'update account_checks set account_date_time = account_date_time + 1/24/60/60 where rowid = ''' || row_id || '''' as sql_text
		from	(
			select	account_date_time, account_set, policy_number, count(*), max(rowid) row_id
			from	account_checks
			group by account_date_time, account_set, policy_number
			having count(*) > 1
			) )
	loop
		--dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
	commit;
end;
/

create unique index accountchecks_idx1 on account_checks
	( account_date_time, account_set, policy_number )
tablespace advocate_data;

--create unique index accountchecks_idx2 on account_checks
--	( check_guid, check_type )
--tablespace advocate_data;


begin
	for r in(
		select	'delete from pb_detail where rowid = ''' || row_id || '''' as sql_text
		from	(
			select	policy_number, policy_date_time, count(*), max(rowid) row_id
			from	pb_detail
			group by policy_number, policy_date_time
			having count(*) > 1
			) )
	loop
		--dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
	commit;
end;
/

create unique index pb_detail_idx1 on pb_detail
	( policy_number, policy_date_time )
tablespace advocate_data;

begin
	for r in(
		select	'delete from commission_detail where rowid = ''' || row_id || '''' as sql_text
		from	(
			select	policy_number, policy_date_time, tier, premium_lob, count(*), max(rowid) row_id
			from	commission_detail
			group by policy_number, policy_date_time, tier, premium_lob
			having count(*) > 1
			) )
	loop
		--dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
	commit;
end;
/

create unique index commission_detail_idx on commission_detail
	( policy_number, policy_date_time, tier, premium_lob )
tablespace advocate_data;

begin
	for r in(
		select	'delete from pb_varname where rowid = ''' || row_id || '''' as sql_text
		from	(
			select	policy_number, policy_date_time, sequence_number, count(*), max(rowid) row_id
			from	pb_varname
			group by policy_number, policy_date_time, sequence_number
			having count(*) > 1
			) )
	loop
		--dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
	commit;
end;
/

create unique index pb_varname_idx1 on pb_varname
	( policy_number, policy_date_time, sequence_number )
tablespace advocate_data;

create unique index policy_pk on policy
	( policy_number, policy_date_time )
tablespace advocate_data;

begin
	for r in(
		select	'delete from pb_vardata1 where rowid = ''' || row_id || '''' as sql_text
		from	(
			select	policy_number, policy_date_time, sequence_number, count(*), max(rowid) row_id
			from	pb_vardata1
			group by policy_number, policy_date_time, sequence_number
			having count(*) > 1
			) )
	loop
		--dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
	commit;
end;
/

create unique index pb_vardata1_idx1 on pb_vardata1
	( policy_number, policy_date_time, sequence_number )
tablespace advocate_data;

@/dba/admin/advocate/CNV_CD37909.sql
@/dba/admin/advocate/CNV_CR37909.sql
@/dba/admin/advocate/CNV_CX37909.sql

commit;

exit;
EOF
