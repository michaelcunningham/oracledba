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

ORACLE_SID=$1

. /dba/admin/dba.lib

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

admin_dir=/dba/admin
log_dir=$admin_dir/log
log_file=$log_dir/${ORACLE_SID}_tablespace_expansion_report.log

####################################################################################################
#
# Create a report for estimated times for stats.
#
####################################################################################################
sqlplus -s /nolog << EOF > $log_file
connect / as sysdba
set serveroutput on
set feedback off

declare
	/*
		This pl/sql will be used to pre-expand tablespaces in the middle of the
		night so we don't suffer the performance hit of an autoexpand in the
		middle of the production day.

		Any tablespace that has less than 2GB of free space will be a candidate
		for expansion.  However, for now we are only going to look at
		NOVA and NOVAIX tablespaces.
	*/
	cursor	cur_datafile( p_tablespace_name varchar2 ) is
		select	file_name, bytes, maxbytes, avail_for_growth
		from	(
			select	file_name, bytes, maxbytes, min( maxbytes-bytes ) avail_for_growth
			from	sys.dba_data_files
			where	tablespace_name = p_tablespace_name
			and	bytes <> maxbytes
			group by file_name, bytes, maxbytes
			order by 4
			)
		where	rownum = 1;

	r_datafile		cur_datafile%rowtype;
	s_sql			varchar2(500);
	n_new_tablespace_size	number;
	s_new_tablespace_size	varchar2(20);
	c_2GB			constant integer := 2147483648;
begin
	--
	-- Find tablespaces that have less than 2GB of free space.
	--
	for r in(
		select	tablespace_name, sum( bytes ) bytes
		from	sys.dba_free_space
		where	tablespace_name in( 'NOVA', 'NOVAIX' )
		group by tablespace_name
		having sum( bytes ) < c_2GB )
	loop
		open cur_datafile( r.tablespace_name );
		fetch cur_datafile into r_datafile;

		if cur_datafile%notfound then
			--
			-- I might do something here in the future, but for now just return
			-- since there is nothing to do.
			--
			dbms_output.put_line( 'There are no tablespaces that need expansion today.' );
			return;
		else
			--
			-- At this point we know what datafile we are going to expand.
			-- Let's do some calculations to insure we are expanding in GB increments.
			-- At the same time we will make sure we increase by at least 2GB.
			--
			n_new_tablespace_size := r_datafile.bytes + c_2GB;
			n_new_tablespace_size := ceil( n_new_tablespace_size / 1024/1024/1024 );

			--
			-- The max size of a datafile is 32GB so make sure it is not larger than that.
			--
			if n_new_tablespace_size > 128 then
				n_new_tablespace_size := 128;
			end if;

			if n_new_tablespace_size = 128 then
				s_new_tablespace_size := '137438953472';
			else
				s_new_tablespace_size := n_new_tablespace_size || 'g';
			end if;

			dbms_output.put_line( 'The ' || r.tablespace_name || ' tablespace is being extended.' );
			dbms_output.put_line( 'The ' || r_datafile.file_name || ' datafile will be extended from '
				|| r_datafile.bytes / 1024/1024/1024 || 'g to ' || n_new_tablespace_size || 'g.' );

			s_sql := 'alter database datafile ''' || r_datafile.file_name || ''' resize ' || s_new_tablespace_size;
			dbms_output.put_line( '	' );
			dbms_output.put_line( '	' || s_sql );
			dbms_output.put_line( '	' );

			execute immediate s_sql;
		end if;

		close cur_datafile;
	end loop;
end;
/

exit;
EOF

if [ ! -s $log_file ]
then
  echo 'There are no tablespaces that need expansion today.' > $log_file
fi

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

mail -s "${ORACLE_SID} - Tablespace Expansion Report" `cat /dba/admin/dba_team` < $log_file
