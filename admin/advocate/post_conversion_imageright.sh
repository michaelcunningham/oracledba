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
username=imageright_user
userpwd=`get_user_pwd $tns $username`

log_file=/dba/admin/advocate/log/post_conversion_imageright_${ORACLE_SID}.log

if [ "$userpwd" = "" ]
then
  echo
  echo "   The user \"$username\" was not found in the oraid file."
  echo
  exit
fi

sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd

begin
	for r in(
		select	'delete from folder where rowid = ''' || row_id || '''' as sql_text
		from	(
			select	docfolderid, count(*), max(rowid) row_id
			from	folder
			group by docfolderid
			having count(*) > 1
			) )
	loop
		--dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
	commit;
end;
/

commit;

create unique index pk_folder on folder
	( docfolderid )
tablespace imageright_data;

exit;
EOF
