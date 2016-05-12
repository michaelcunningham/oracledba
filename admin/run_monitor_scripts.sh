#!/bin/sh

# /mnt/dba/adhoc/license/scripts/run_ora_license_scripts.sh > /dev/null

/mnt/dba/admin/backup_crontab.sh
/mnt/dba/admin/backup_dbs_dirs.sh
/mnt/dba/admin/restart_cloud_control_agent.sh

# /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/chk_external_directory_status.sh
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_db_info.sh
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_db_links.sh
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_feature_usage_info.sh
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_has_db_info.sh
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_segment_history.sh
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_db_archived_log.sh
/mnt/dba/admin/log_server_info.sh

# /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_db_info_UTILDB.sh
# /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_db_links_UTILDB.sh
# /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_has_db_info_UTILDB.sh
# /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_segment_history_UTILDB.sh

/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/chk_db_link_status.sh
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/chk_dg_status.sh
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/load_schema_compare.sh
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/db_segment_monitor.sh
# /mnt/dba/admin/chk_asm_spare_candidate_disk.sh
# /mnt/dba/admin/chk_asm_spfile.sh
