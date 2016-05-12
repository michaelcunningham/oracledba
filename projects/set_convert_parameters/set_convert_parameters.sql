spool /mnt/dba/projects/set_convert_parameters/logs/set_convert_parameters_&_CONNECT_IDENTIFIER..log
alter system set db_file_name_convert='/noop/','/noop/' scope=spfile;
alter system set log_file_name_convert='/noop/','/noop/' scope=spfile;
create pfile from spfile;
