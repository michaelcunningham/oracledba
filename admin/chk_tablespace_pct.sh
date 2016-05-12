#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_chk_tablespace_pct.log
lock_file=${log_dir}/${ORACLE_SID}_tablespace_pct.lock
EMAILDBA=dba@tagged.com
PAGEDBA=dbaoncall@tagged.com

database_role=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select database_role from v\\$database;
exit;
EOF`

database_role=`echo $database_role`

if [ "$database_role" != "PRIMARY" ]
then
  # This script is only intended to be run on PRIMARY databases.
  # This is not a PRIMARY, so exit.
  exit
fi

> $log_file

#
# Check all tablespaces to see if they are below a graduated threshold for pct free.
#

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba
set feedback off
set linesize 104
set serveroutput on

declare
	n_pct_free_threshold	number;
	n_TB			number := 1099511627776;
	b_header_printed	boolean := false;
	s_output		varchar2(200);
begin
	for r in(
		select	tablespace_name, total_bytes, total_maxbytes, used_bytes, free_bytes,
			to_char( ( used_bytes / total_bytes ) * 100, '990.00' ) pct_used, 
			to_char( ( ( total_maxbytes - used_bytes ) / total_maxbytes ) * 100, '990.00' ) pct_free,
			'addspace' status 
		from	(
			select	ddf.tablespace_name,
				sum( ddf.sum_bytes ) total_bytes,
				sum( ddf.sum_bytes ) - nvl( sum( dfs.free_bytes ), 0 ) used_bytes,
				nvl( sum( dfs.free_bytes ), 0 ) free_bytes,
				sum( sum_maxbytes ) total_maxbytes
			from	(
				select	tablespace_name, sum( bytes ) sum_bytes,
					sum( decode( autoextensible, 'YES', maxbytes, bytes ) ) sum_maxbytes
				from	dba_data_files
				group by tablespace_name
				) ddf,
				(
				select	tablespace_name, sum( bytes ) free_bytes
				from	dba_free_space
				group by tablespace_name
				) dfs
			where	ddf.tablespace_name = dfs.tablespace_name(+)
			group by ddf.tablespace_name
			order by ddf.tablespace_name
			)
		where	tablespace_name not in( 'SYSTEM', 'SYSAUX', 'UNDOTBS', 'UNDOTBS1', 'PERFSTAT' )
		)
	loop
		--dbms_output.put_line( 'TBS = ' || r.tablespace_name || ' / Bytes = ' || r.total_bytes );

		if r.total_bytes < n_TB * 1 then
			n_pct_free_threshold := 10.0;
		elsif r.total_bytes < n_TB * 2 then
			n_pct_free_threshold := 6.0;
		elsif r.total_bytes < n_TB * 3 then
			n_pct_free_threshold := 4.0;
		elsif r.total_bytes < n_TB * 4 then
			n_pct_free_threshold := 3.0;
		elsif r.total_bytes < n_TB * 5 then
			n_pct_free_threshold := 2.5;
		else
			n_pct_free_threshold := 2.0;
		end if;

		--dbms_output.put_line( r.total_bytes || ' ' || n_pct_free_threshold || ' ' || r.pct_free );

		--dbms_output.put_line( 'PCT Free = ' || r.pct_free || ' / Threshold = ' || n_pct_free_threshold );

		if r.pct_free < n_pct_free_threshold then
			if b_header_printed = false then
				dbms_output.put_line( 'Tablespace Name                     Total (MB)  Total Max (MB)       Free MB   Used%   Free%  Status' );
				dbms_output.put_line( '------------------------------  --------------  --------------  ------------  ------  ------  --------' );
				b_header_printed := true;
			end if;

			s_output := rpad( r.tablespace_name, 30 );
			s_output := s_output || lpad( to_char( r.total_bytes/1024/1024, '999,999,999' ), 16 );
			s_output := s_output || lpad( to_char( r.total_maxbytes/1024/1024, '999,999,999' ), 16 );
			--s_output := s_output || lpad( to_char( r.used_bytes/1024/1024, '999,999,999' ), 16 );
			s_output := s_output || lpad( to_char( r.free_bytes/1024/1024, '999,999,999' ), 14 );
			s_output := s_output || lpad( to_char( r.pct_used, '990.00' ), 8 );
			s_output := s_output || lpad( to_char( r.pct_free, '990.00' ), 8 );
			s_output := s_output || '  ' || r.status;
			dbms_output.put_line( s_output );
		end if;
	end loop;
end;
/

exit;
EOF

#
# If there is a log file then there was either an error with the script
# or, at least, one tablespace that is beyond the threshold.
# Check to see if it was an error or if space needs to be added.
#
if [ -s $log_file ]
then
  cat $log_file | grep "ORA-" > /dev/null
  if [ $? -eq 0 ]
  then
    mail_subj="WARNING: Tablespace PCT Check Failed"
  else
    mail_subj="NOTICE: Adding space in $ORACLE_SID"
    addspace=true
  fi
  mail -s "$mail_subj" $EMAILDBA < $log_file
fi

#
# An email was likely sent indicating space would be added to the database.
# Let's add the space.
#
if [ "$addspace" = "true" ]
then
  for this_tablespace in `cat $log_file | grep addspace$ | awk '{print $1}'`
  do
    /mnt/dba/admin/add_datafile_to_tablespace.sh $ORACLE_SID $this_tablespace
  done
fi
