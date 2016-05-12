--
-- This is to create the external directory used for loading data from level db CSV files.
--
-- Run this as SYS
--
create or replace directory ext_clamor_dir as '/mnt/db_transfer/clamor/messages';
grant read, write on directory ext_clamor_dir to tag;
