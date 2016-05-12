set echo on
set time on timing on

spool create_sora02_datatbs1.log

CREATE TABLESPACE P20150415_20150724_TBS DATAFILE
'+IMDBDATADELME' SIZE 30721m AUTOEXTEND OFF
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO;

alter tablespace P20150415_20150724_TBS add datafile '+IMDBDATADELME' size 30721m;
alter tablespace P20150415_20150724_TBS add datafile '+IMDBDATADELME' size 30721m;
alter tablespace P20150415_20150724_TBS add datafile '+IMDBDATADELME' size 30721m;
alter tablespace P20150415_20150724_TBS add datafile '+IMDBDATADELME' size 30721m;
alter tablespace P20150415_20150724_TBS add datafile '+IMDBDATADELME' size 30721m;
alter tablespace P20150415_20150724_TBS add datafile '+IMDBDATADELME' size 30721m;
alter tablespace P20150415_20150724_TBS add datafile '+IMDBDATADELME' size 30721m;
alter tablespace P20150415_20150724_TBS add datafile '+IMDBDATADELME' size 30721m;
alter tablespace P20150415_20150724_TBS add datafile '+IMDBDATADELME' size 30721m;

spool off

