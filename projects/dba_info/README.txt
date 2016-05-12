#
# To install the dbainfo module do the following.
#

# Login as SYS and run the following
        grant create materialized view to tag;
        grant create trigger to tag;

# Login as TAG and run the following
	create_db_info_objects.sql
	create_db_link_objects.sql
        create_db_segment_history_objects.sql
	create_has_db_info_objects.sql
