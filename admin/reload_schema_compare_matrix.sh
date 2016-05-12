#!/bin/sh

unset SQLPATH
export ORACLE_SID=WHSE
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

username=taggedmeta
userpwd=taggedmeta123

####################################################################################################
#
# Alternatives to loading the entire matrix
#
# exec schema_compare.load_shard_matrix( 'MMDB', 'Production' );
#         -- The procedure call above calls these 4 procedures below
#         exec schema_compare.load_tables_shard_matrix( 'MMDB', 'Production' );
#         exec schema_compare.load_tab_columns_shard_matrix( 'MMDB', 'Production' );
#         exec schema_compare.load_indexes_shard_matrix( 'MMDB', 'Production' );
#         exec schema_compare.load_ind_columns_shard_matrix( 'MMDB', 'Production' );
#
# exec schema_compare.load_noshard_matrix( 'MMDB', 'Production' );
#         -- The procedure call above calls these 4 procedures below
#         exec schema_compare.load_tables_noshard_matrix( 'MMDB', 'Production' );
#         exec schema_compare.load_tab_columns_noshard_mtrx( 'MMDB', 'Production' );
#         exec schema_compare.load_indexes_noshard_matrix( 'MMDB', 'Production' );
#         exec schema_compare.load_ind_columns_noshard_mtrx( 'MMDB', 'Production' );
#
####################################################################################################

sqlplus -s /nolog << EOF
connect $username/$userpwd

set feedback off
--set serveroutput on size unlimited

begin
	schema_compare.load_shard_matrix_all;
end;
/

exit;
EOF
