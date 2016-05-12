#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 novadev"
  echo
  exit
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
username=novaprd
userpwd=`get_user_pwd $tns $username`

admin_dir=/dba/admin
admin_log_dir=/dba/admin/log
log_file=$admin_log_dir/${ORACLE_SID}_touch_missing_external_files.log

sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd

set serveroutput on

declare
	b_exists	boolean;
	n_file_size	number;
	n_block_size	number;
	h_file		utl_file.file_type;
begin
	for et in(
		select	uet.table_name, uel.directory_name, uel.location
		from	user_external_tables uet, user_external_locations uel
		where	uet.table_name = uel.table_name )
	loop
		utl_file.fgetattr( et.directory_name, et.location,
				b_exists, n_file_size, n_block_size );
		if not b_exists then
			dbms_output.put_line( 'Touching external file ... ' || et.location);
			h_file := utl_file.fopen( et.directory_name, et.location, 'w', 1 );
			utl_file.fclose( h_file );
		end if;
	end loop;

end;
/

EOF

