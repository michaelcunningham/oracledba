startup nomount
CREATE CONTROLFILE SET DATABASE "UTILDB" RESETLOGS FORCE LOGGING ARCHIVELOG
    MAXLOGFILES 40
    MAXLOGMEMBERS 3
    MAXDATAFILES 100
    MAXINSTANCES 8
    MAXLOGHISTORY 1168
LOGFILE
  GROUP 1 '/u02/oradata/UTILDB/redo/log01.dbf'  SIZE 50M BLOCKSIZE 512,
  GROUP 2 '/u02/oradata/UTILDB/redo/log02.dbf'  SIZE 50M BLOCKSIZE 512,
  GROUP 3 '/u02/oradata/UTILDB/redo/log03.dbf'  SIZE 50M BLOCKSIZE 512
DATAFILE
  '/u02/oradata/UTILDB/data/system01.dbf',
  '/u02/oradata/UTILDB/data/sysaux01.dbf',
  '/u02/oradata/UTILDB/data/undo01.dbf',
  '/u02/oradata/UTILDB/data/users01.dbf',
  '/u02/oradata/UTILDB/data/datatbs101.dbf'
CHARACTER SET AL32UTF8
;
ALTER DATABASE OPEN RESETLOGS;
