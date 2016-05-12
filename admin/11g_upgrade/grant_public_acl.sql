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
