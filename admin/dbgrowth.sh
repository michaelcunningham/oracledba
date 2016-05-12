#!/bin/sh
#####################################################
# This is a script to track daily tablespace size, 
# also the extents for tables, indexes, and datafiles
# over half a meg in size.
#
# ddm 08/06/2012 Created.
#####################################################
#Set variables

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 svdev"
  echo
  exit
fi

. /dba/admin/dba.lib

export ORACLE_SID=$1
export ORAENV_ASK=NO
tns=`get_tns_from_orasid $ORACLE_SID`

. /usr/local/bin/oraenv

sqlplus -s "/ as sysdba" << EOF 
set echo on;
set term off;                                                                
set verify off;                                                              
set feedback on;                                                            
set pagesize 0 heading off timing off linesize 130;                           
delete from system.aa_dbgrowth_tspace where edate = trunc(sysdate)
/
insert into system.aa_dbgrowth_tspace (edate,tablespace_name,file_name,total_alloc,total_free)
select
trunc(sysdate)
,alloc.tablespace_name
,alloc.file_name
,alloc.bytes
,nvl(free.total_free,0)
from 
dba_data_files alloc,
(select file_id, sum(bytes) total_free from dba_free_space group by file_id) free 
where alloc.file_id = free.file_id(+)
/
delete from system.aa_dbgrowth_extents where edate = trunc(sysdate)
/
insert into system.aa_dbgrowth_extents
(edate,owner,segment_name,segment_type,tablespace_name,bytes,extents)
select trunc(sysdate)
,owner
,segment_name
,segment_type
,tablespace_name
,bytes
,extents
from dba_segments where segment_type in ('TABLE','INDEX')
and bytes > 524288
/
exit;
EOF
