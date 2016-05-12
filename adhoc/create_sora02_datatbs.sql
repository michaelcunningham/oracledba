set echo on
set time on timing on

spool create_sora02_datatbs1.log

CREATE TABLESPACE DATATBS1 DATAFILE 
'+STAGEDATA' SIZE 30G AUTOEXTEND OFF
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO;

alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;

spool off
