#!/bin/sh

CMD="mail"
# CMD="uptime"
# CMD="/mnt/dba/admin/meminfo.sh | grep \"Huge Memory\""
# CMD="ls -l /tmp/data_load_test"
# CMD="find /u01/app/oracle/product/*/*/dbs -name *STAGDB.ora"
# CMD="grep data_load /home/oracle/.bash_history"
# CMD="/mnt/dba/admin/asm_diskstring.sh"
# CMD="/mnt/dba/admin/run_script_all_sid_primary.sh /mnt/dba/scripts/temp.sql"
# CMD="/mnt/dba/admin/run_script_all_sid_primary.sh /mnt/dba/scripts/show_diag_usage.sql"
# CMD="/mnt/dba/admin/run_script_all_sid_primary.sh /mnt/dba/scripts/show_adg.sql"
# CMD="/mnt/dba/admin/run_script_all_sid.sh /mnt/dba/scripts/show_adg.sql"
CMD="/mnt/dba/admin/run_script_all_sid.sh /mnt/dba/scripts/implement_resource_plan.sql"
# CMD="/mnt/dba/admin/run_script_all_sid.sh /mnt/dba/scripts/show_compression_info.sql"
# CMD="/mnt/dba/admin/run_script_all_sid.sh /mnt/dba/scripts/show_aco_usage.sql"
# CMD="/mnt/dba/admin/run_script_all_sid.sh /mnt/dba/scripts/chk_partitioning_usage.sql"
# CMD="/mnt/dba/admin/run_script_all_sid_primary.sh /mnt/dba/scripts/syn_orphans_show.sql"
# CMD="/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/drop_stage1_db_link.sh"
# CMD="/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_segment_history.sh"
# CMD="/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/create/create_tag_read_user.sh"
# CMD="/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/tickets/DBA-6278/run_create.sh"
# CMD="/mnt/dba/admin/chk_asm_spare_candidate_disk.sh"
# CMD="/mnt/dba/admin/backup_dbs_dirs.sh"
# CMD="ls -1 /u01/app/12.1.0.1/grid/rdbms/audit | wc -l"
# CMD="ps x | grep backup"
# CMD="df -m | grep backup"
# CMD="md5sum /u01/app/oracle/admin/common_scripts/backup_database_PDB.sh"
# CMD="md5sum /usr/local/bin/oraenv"
# CMD="md5sum /usr/local/bin/dbhome"
# CMD="md5sum /u01/app/oracle/admin/common_scripts/check.sh"
# CMD="find /u01/app/oracle/diag/rdbms/*/*/trace -name alert*.log -exec grep ORA-10561 {} \;"
# CMD="ls -l /etc/rc.d/init.d/gcstartup"
# CMD="ls -l /home/oracle/dba | grep upgrade"
# CMD="find /home/oracle/dba -name recover*"
# CMD="scp -p dbmon04:/u01/app/oracle/admin/common_scripts/check.sh /u01/app/oracle/admin/common_scripts/check.sh"
# CMD="/mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/DBA-5926/DBA-5926.sql"

# Primary PDB
echo ".................... ora11"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora11 "$CMD"
echo ".................... ora05"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora05 "$CMD"
echo ".................... ora14"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora14 "$CMD"
echo ".................... ora16"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora16 "$CMD"
echo ".................... ora13"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora13 "$CMD"
echo ".................... ora01"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora01 "$CMD"
echo ".................... ora02"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora02 "$CMD"
echo ".................... ora03"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora03 "$CMD"

# Primary TDB
echo ".................... ora30"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora30 "$CMD"
echo ".................... ora31"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora31 "$CMD"
echo ".................... ora33"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora33 "$CMD"
echo ".................... ora35"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora35 "$CMD"

# Primary TAGDB & MMDB
echo ".................... ora27"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora27 "$CMD"
echo ".................... ora20"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora20 "$CMD"
echo ".................... ora26"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora26 "$CMD"

# WHSE
echo ".................... ora39"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora39 "$CMD"

# IMDB
echo ".................... ora41"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora41 "$CMD"

# Dev and Stage
echo ".................... dora02"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora02 "$CMD"
echo ".................... dora10"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora10 "$CMD"
echo ".................... dora11"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora11 "$CMD"
echo ".................... dora12"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora12 "$CMD"
echo ".................... dora13"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora13 "$CMD"
echo ".................... dora14"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora14 "$CMD"
echo ".................... dora15"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora15 "$CMD"
echo ".................... dora16"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora16 "$CMD"
echo ".................... dora17"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora17 "$CMD"
echo ".................... dora18"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora18 "$CMD"
echo ".................... dora19"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora19 "$CMD"
echo ".................... dora20"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora20 "$CMD"
echo ".................... dora21"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora21 "$CMD"
echo ".................... dora22"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora22 "$CMD"

echo ".................... sora02"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora02 "$CMD"

echo ".................... sora03"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora03 "$CMD"
echo ".................... sora10"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora10 "$CMD"
echo ".................... sora11"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora11 "$CMD"
echo ".................... sora12"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora12 "$CMD"
echo ".................... sora13"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora13 "$CMD"
echo ".................... sora14"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora14 "$CMD"
echo ".................... sora15"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora15 "$CMD"
echo ".................... sora16"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora16 "$CMD"
echo ".................... sora17"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora17 "$CMD"
echo ".................... sora18"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora18 "$CMD"
echo ".................... sora20"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora20 "$CMD"
echo ".................... sora21"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora21 "$CMD"
echo ".................... sora22"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora22 "$CMD"
echo ".................... sora23"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora23 "$CMD"
echo ".................... sora24"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora24 "$CMD"
echo ".................... sora25"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora25 "$CMD"

# exit

# Standby PDB
echo ".................... ora17"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora17 "$CMD"
echo ".................... ora18"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora18 "$CMD"
echo ".................... ora19"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora19 "$CMD"
echo ".................... ora07"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora07 "$CMD"
echo ".................... ora22"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora22 "$CMD"
echo ".................... ora23"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora23 "$CMD"
echo ".................... ora24"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora24 "$CMD"
echo ".................... ora15"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora15 "$CMD"

# Standby TDB
echo ".................... ora29"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora29 "$CMD"
echo ".................... ora32"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora32 "$CMD"
echo ".................... ora34"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora34 "$CMD"
echo ".................... ora36"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora36 "$CMD"

# Standby TAGDB & MMDB
echo ".................... ora28"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora28 "$CMD"
echo ".................... ora25"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora25 "$CMD"
echo ".................... ora21"
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora21 "$CMD"
