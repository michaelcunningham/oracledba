####################################################################################################
#
# To save schema or table stats for a particular schema (ie. TAG) do the following
#
####################################################################################################
/mnt/dba/admin/stats/stats_create_stats_table.sh <ORACLE_SID> <username>
	Use this script to create the "stats_history" table in a schema.
	It will be used to save the schema statistics.

	Example:
		/mnt/dba/admin/stats/stats_create_stats_table.sh IMDB01 tag


/mnt/dba/admin/stats/stats_save_schema_stats.sh <ORACLE_SID> <username> <label for stats>
	Use this script to save the schema statistics into the stats_history table.
	The stats_history table can then be exported so the statistics can be used in other databases.

	Example:
		/mnt/dba/admin/stats/stats_save_schema_stats.sh IMDB01 tag stats_20160329_1023


/mnt/dba/admin/stats/stats_save_table_stats.sh <ORACLE_SID> <username> <label for stats>
	Use this script to save the statistics into the stats_history table for a single table.

	Example:
		/mnt/dba/admin/stats/stats_save_table_stats.sh IMDB01 tag stats_20160329_1023


####################################################################################################
#
# To restore schema stats do the following
#
####################################################################################################
/mnt/dba/admin/stats/stats_restore_schema_stats.sh <ORACLE_SID> <username> <label for stats>
        Use this script to restore the schema statistics from the stats_history table.

        Example:
                /mnt/dba/admin/stats/stats_restore_schema_stats.sh IMDB01 tag stats_20160329_1023


####################################################################################################
#
# To restore table stats do the following
#
####################################################################################################
/mnt/dba/admin/stats/stats_restore_table_stats.sh <ORACLE_SID> <username> <label for stats>
        Use this script to restore the statistics from the stats_history table for a single table.

        Example:
                /mnt/dba/admin/stats/stats_restore_table_stats.sh IMDB01 tag messages stats_20160101
