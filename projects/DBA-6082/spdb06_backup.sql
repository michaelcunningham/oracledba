--
--     Set #2. RESETLOGS case
--
-- The following commands will create a new control file and use it
-- to open the database.
-- Data used by Recovery Manager will be lost.
-- The contents of online logs will be lost and all backups will
-- be invalidated. Use this only if online logs are damaged.
-- After mounting the created controlfile, the following SQL
-- statement will place the database in the appropriate
-- protection mode:
--  ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE PERFORMANCE
STARTUP NOMOUNT pfile='/u01/app/oracle/product/12.1.0.1/dbhome_1/dbs/initSPDB06.ora';
CREATE CONTROLFILE SET DATABASE "SPDB06" RESETLOGS NOARCHIVELOG
    MAXLOGFILES 40
    MAXLOGMEMBERS 3
    MAXDATAFILES 100
    MAXINSTANCES 8
    MAXLOGHISTORY 1168
LOGFILE
  GROUP 1 '/u02/oradata/SPDB06/redo/log01.ora'  SIZE 1024M BLOCKSIZE 512,
  GROUP 2 '/u02/oradata/SPDB06/redo/log02.ora'  SIZE 1024M BLOCKSIZE 512,
  GROUP 3 '/u02/oradata/SPDB06/redo/log03.ora'  SIZE 1024M BLOCKSIZE 512,
  GROUP 4 '/u02/oradata/SPDB06/redo/log04.ora'  SIZE 1024M BLOCKSIZE 512,
  GROUP 5 '/u02/oradata/SPDB06/redo/log05.ora'  SIZE 1024M BLOCKSIZE 512,
  GROUP 6 '/u02/oradata/SPDB06/redo/log06.ora'  SIZE 1024M BLOCKSIZE 512,
  GROUP 7 '/u02/oradata/SPDB06/redo/log07.ora'  SIZE 1024M BLOCKSIZE 512,
  GROUP 8 '/u02/oradata/SPDB06/redo/log08.ora'  SIZE 1024M BLOCKSIZE 512,
  GROUP 9 '/u02/oradata/SPDB06/redo/log09.ora'  SIZE 1024M BLOCKSIZE 512,
  GROUP 10 '/u02/oradata/SPDB06/redo/log10.ora'  SIZE 1024M BLOCKSIZE 512
-- STANDBY LOGFILE
DATAFILE
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-SYSTEM_FNO-1',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-UNDOTBS1_FNO-2',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-SYSAUX_FNO-3',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-USERS_FNO-4',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-DATATBS1_FNO-5',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-INDXTBS1_FNO-6',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-DATATBS1_FNO-7',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-DATATBS1_FNO-8',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-DATATBS1_FNO-9',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-INDXTBS1_FNO-10',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-INDXTBS1_FNO-11',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-DATATBS1_FNO-12',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-DATATBS1_FNO-13',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P16TBS_FNO-14',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P17TBS_FNO-15',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P18TBS_FNO-16',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P19TBS_FNO-17',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P20TBS_FNO-18',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P21TBS_FNO-19',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P22TBS_FNO-20',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P23TBS_FNO-21',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P24TBS_FNO-22',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P25TBS_FNO-23',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P26TBS_FNO-24',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P27TBS_FNO-25',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P28TBS_FNO-26',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P29TBS_FNO-27',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P30TBS_FNO-28',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-P31TBS_FNO-29',
  '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-DATATBS1_FNO-30'
CHARACTER SET WE8MSWIN1252
;
-- Configure RMAN configuration record 1
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('RETENTION POLICY','TO REDUNDANCY 1');
-- Configure RMAN configuration record 2
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE','DISK TO ''/mnt/db_transfer/SPDB06/rman_backup/%F''');
-- Configure RMAN configuration record 3
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('MAXSETSIZE TO','50 G');
-- Configure RMAN configuration record 4
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('SNAPSHOT CONTROLFILE NAME','TO ''/mnt/db_transfer/PDB06/rman_backup/ctl/snapcf_SPDB06.f''');
-- Commands to re-create incarnation table
-- Below log names MUST be changed to existing filenames on
-- disk. Any one log file from each branch can be used to
-- re-create incarnation records.
-- ALTER DATABASE REGISTER LOGFILE '/u02/oradata/SPDB06/arch/1_1_649125521.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u02/oradata/SPDB06/arch/1_1_767899096.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u02/oradata/SPDB06/arch/1_1_891361745.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u02/oradata/SPDB06/arch/1_1_900575088.dbf';
-- Recovery is required if any of the datafiles are restored backups,
-- or if the last shutdown was not normal or immediate.
--RECOVER DATABASE USING BACKUP CONTROLFILE
-- Database can now be opened zeroing the online logs.
ALTER DATABASE OPEN RESETLOGS;
-- Files in read-only tablespaces are now named.
ALTER DATABASE RENAME FILE 'MISSING00031'
  TO '/u02/oradata/SPDB06/data/data_D-SPDB06_TS-READTBS_FNO-31';
-- Online the files in read-only tablespaces.
ALTER TABLESPACE "READTBS" ONLINE;
-- Commands to add tempfiles to temporary tablespaces.
-- Online tempfiles have complete space information.
-- Other tempfiles may require adjustment.
ALTER TABLESPACE TEMP ADD TEMPFILE '/u02/oradata/SPDB06/data/data_D-STGPRT02_TS-TEMP_FNO-1'
     SIZE 20971520  REUSE AUTOEXTEND ON NEXT 655360  MAXSIZE 32767M;
-- End of tempfile additions.
--
