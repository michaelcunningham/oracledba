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
username=novaprd
userpwd=`get_user_pwd $tns $username`

sqlplus -s /nolog << EOF
connect / as sysdba

begin
	begin
		dbms_network_acl_admin.drop_acl( 'all-network-public.xml' );
	exception
		when others then null;
	end;

	dbms_network_acl_admin.create_acl( 'all-network-public.xml',
		'Open connectivity for all network connections',
		'PUBLIC', true, 'connect' );
	dbms_network_acl_admin.add_privilege( 'all-network-public.xml',
		'PUBLIC', true, 'resolve' );
	dbms_network_acl_admin.assign_acl( 'all-network-public.xml', '*' );
end;
/

commit;

exit;
EOF

