#
# To install the userdata_light module do the following.
#

/mnt/dba/admin/install_user_lock_package.sh $ORACLE_SID

# Login as SYS and run the following
	grant create job to tag;
	grant create any table to tag;

# Login as TAG and run the following
	create_tables.sql
	USERDATA_LIGHT_PKG.pks
	USERDATA_LIGHT_PKG.pkb
