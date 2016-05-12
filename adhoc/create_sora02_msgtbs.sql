set echo on
set time on timing on

spool create_sora02_msgtbs.log

CREATE TABLESPACE MSGTBS1 DATAFILE 
'+STAGEDATA' SIZE 30G AUTOEXTEND OFF
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO;

alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace MSGTBS1 add datafile '+STAGEDATA' size 30G;

spool off
