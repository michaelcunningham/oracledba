#!/bin/sh

export ORACLE_SID=PDB04

export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus /nolog << EOF
connect / as sysdba

alter system set dg_broker_start=false scope=spfile;
alter system set fal_client=pdb04a scope=spfile;
alter system set db_unique_name=pdb04a scope=spfile;
alter system set service_names='PDB04, PDB04A';
alter system set db_file_name_convert='/PDB04B/','/PDB04A/' scope=spfile;
alter system set log_file_name_convert='/PDB04B/','/PDB04A/' scope=spfile;
alter system set log_archive_dest_1='LOCATION=+LOGPDB04 VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=PDB04A' scope=spfile;

exit;
EOF
