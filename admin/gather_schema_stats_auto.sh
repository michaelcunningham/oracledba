#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <schema>"
  echo
  echo "   Example: $0 svdev vistadev"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

echo
echo "############ Gathering statistics for : "$ORACLE_SID" "$2" - "`date "+%b %d %Y %H:%M %p"`
echo

sqlplus -s /nolog <<EOF
connect / as sysdba
begin
	for r in (
		select	owner, table_name
		from	dba_external_tables
		where	owner = upper( '$2' ) )
	loop
	--	dbms_output.put_line( r.owner || '.' || r.table_name );
		dbms_stats.delete_table_stats( r.owner, r.table_name, cascade_indexes => true );
	end loop;
end;
/

begin 
	dbms_stats.gather_schema_stats( '$2', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size, options => 'GATHER EMPTY' );
	dbms_stats.gather_schema_stats( '$2', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size, options => 'GATHER STALE' );
end; 
/ 

exit;
EOF
exit 0

