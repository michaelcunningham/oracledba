#!/bin/sh

# PDB databases
ssh ora11 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora05 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora14 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora16 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora13 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora37 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora02 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora03 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh

# TDB databases
ssh ora29 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora31 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora33 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora35 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh

# TAGDB database
ssh ora27 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh

# MMDB databases
ssh ora25 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
ssh ora26 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh

# WHSE database
ssh ora39 /mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/log_object_usage_audit.sh
