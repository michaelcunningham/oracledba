#!/bin/sh

# Primary PDB
ssh ora11 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora05 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora14 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora16 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora13 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora37 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora02 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora03 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql

# Primary TDB
ssh ora29 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora31 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora33 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora35 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql

# Primary TAGDB & MMDB
ssh ora27 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora25 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora26 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql

# Standby PDB
ssh ora17 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora18 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora19 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora12 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora22 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora23 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora24 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora15 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql

# Standby TDB
ssh ora30 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora32 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora34 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora36 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql

# Standby TAGDB & MMDB
ssh ora28 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora20 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
ssh ora21 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql

# Dev and Stage
# ssh dora02 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
# ssh sora02 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
# ssh sora03 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/set_convert_parameters/set_convert_parameters.sql
