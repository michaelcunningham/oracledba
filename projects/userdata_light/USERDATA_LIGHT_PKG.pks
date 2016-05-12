CREATE OR REPLACE package TAG.userdata_light_pkg as
	--
	-- Requirements for this package.
	--   1)The USER_LOCK package must be created
	--        $ORACLE_HOME/rdbms/admin/userlock.sql
	--   2) TAG user requires following privileges
	--         grant create job to tag;
	--         grant execute_catalog_role to tag;
	--
	procedure refresh_userdata_light( ps_db_link_prefix_tdb varchar2, ps_db_link_prefix_pdb varchar2 );

	procedure refresh_userdata_light_part1( ps_db_link_prefix_tdb varchar2 );
	procedure refresh_userdata_light_part2( ps_db_link_prefix_tdb varchar2, ps_db_link_prefix_pdb varchar2 );
	procedure refresh_userdata_light_part3( ps_db_link_prefix_tdb varchar2 );
end userdata_light_pkg;
/