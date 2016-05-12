#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <owner>"
  echo
  echo "   Example: $0 novadev novaprd"
  echo
  exit
else
  export ORACLE_SID=$1
  username=$2
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
syspwd=`get_sys_pwd $tns`

log_date=`date +%Y%m%d_%H%M`
treedump_dir=/dba/admin/treedump
log_dir=$treedump_dir/log
log_file=$log_dir/treedump_${ORACLE_SID}_${username}_analyze_schema_retry_${log_date}.log

sqlplus -s /nolog << EOF >> $log_file
connect system/$syspwd

set serveroutput on size unlimited
set linesize 200

exec treedump.set_print( false );
--exec treedump.set_debug( true );

declare
	s_owner		treedump_indexes.owner%type;
	s_index_name	treedump_indexes.index_name%type;

	procedure get_next_index( ps_owner varchar2, ps_index_name in out varchar2 )
	is
		pragma autonomous_transaction;
		s_index_name treedump_indexes.index_name%type;
	begin
		begin
			select	index_name
			into	s_index_name
			from	treedump_indexes
			where	owner = ps_owner
			and	process_status = 'N'
			and	rownum = 1
			for update;
		exception
			when no_data_found then
				commit;
		end;

		if sql%notfound then
			ps_index_name := null;
		else
			ps_index_name := s_index_name;

			-- Set the status to R (Running).
			update	treedump_indexes
			set	process_status = 'R'
			where	owner = ps_owner
			and	index_name = ps_index_name;

			commit;
		end if;
	end get_next_index;
begin
	s_owner := upper( '$username' );
	dbms_output.put_line( 'USERNAME ' || s_owner );
	--
	-- We are going to loop through all the indexes that have Warnings (process_status = 'W').
	-- The easiest way to do this is to set them all to process_status = 'N' then run the
	-- analyze_index for each of the 'N' values.  We can use OPEN/CLOSE because if there is an
	-- issue with analyze_index the process_status will be set to 'W' and the index would not
	-- be selected again.
	--
	update treedump_indexes set process_status = 'N' where process_status = 'W';
	commit;

	get_next_index( s_owner, s_index_name );
	dbms_output.put_line( 'Starting ' || s_index_name );

	while s_index_name is not null
	loop
		dbms_output.put_line( 'Trying ' || s_index_name );
		treedump.analyze_index( s_owner, s_index_name );
		get_next_index( s_owner, s_index_name );
	end loop;
end;
/

exit;
EOF

$treedump_dir/print_schema_report.sh $ORACLE_SID $username
