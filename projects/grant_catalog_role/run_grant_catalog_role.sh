#!/bin/sh

# Primary PDB
ssh ora11 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora05 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora14 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora16 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora13 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora37 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora02 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora03 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql

# Primary TDB
ssh ora29 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora31 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora33 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora35 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql

# Primary TAGDB & MMDB
ssh ora27 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora25 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora26 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql

# Standby PDB
ssh ora17 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora18 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora19 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora12 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora22 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora23 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora24 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora15 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql

# Standby TDB
ssh ora30 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora32 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora34 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora36 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql

# Standby TAGDB & MMDB
ssh ora28 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora20 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh ora21 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql

# Dev and Stage
ssh dora02 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh sora02 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
ssh sora03 /mnt/dba/admin/run_script_all_sid.sh /mnt/dba/projects/grant_catalog_role/grant_catalog_role.sql
