set echo on
set time on timing on

spool create_sora02_tablespaces.log

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
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS1 add datafile '+STAGEDATA' size 30G;

CREATE TABLESPACE INDXTBS1 DATAFILE
'+STAGEDATA' SIZE 30G AUTOEXTEND OFF
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO;

alter tablespace INDXTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace INDXTBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace INDXTBS1 add datafile '+STAGEDATA' size 30G;


CREATE TABLESPACE DATATBS2 DATAFILE
'+STAGEDATA' SIZE 30G AUTOEXTEND OFF
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO;

alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;
alter tablespace DATATBS2 add datafile '+STAGEDATA' size 30G;

CREATE TABLESPACE INDXTBS2 DATAFILE
'+STAGEDATA' SIZE 30G AUTOEXTEND OFF
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO;

alter tablespace INDXTBS2 add datafile '+STAGEDATA' size 30G;

CREATE TABLESPACE DATAQUEUETBS1 DATAFILE
'+STAGEDATA' SIZE 30G AUTOEXTEND OFF
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO;

alter tablespace DATAQUEUETBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATAQUEUETBS1 add datafile '+STAGEDATA' size 30G;
alter tablespace DATAQUEUETBS1 add datafile '+STAGEDATA' size 30G;

CREATE TABLESPACE DATAPETSTBS1 DATAFILE
'+STAGEDATA' SIZE 30G AUTOEXTEND OFF
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO;


CREATE TABLESPACE INDXPETSTBS1 DATAFILE
'+STAGEDATA' SIZE 30G AUTOEXTEND OFF
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO;

spool off
