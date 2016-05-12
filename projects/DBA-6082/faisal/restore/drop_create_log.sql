
define TARGET_SID='SPDB07'



alter database add logfile thread 1 group 21 '/u02/oradata/&TARGET_SID/redo/log01.ora' size 1073741824;
alter database add logfile thread 1 group 22 '/u02/oradata/&TARGET_SID/redo/log02.ora' size 1073741824;
alter database add logfile thread 1 group 23 '/u02/oradata/&TARGET_SID/redo/log03.ora' size 1073741824;
alter database add logfile thread 1 group 24 '/u02/oradata/&TARGET_SID/redo/log04.ora' size 1073741824;
alter database add logfile thread 1 group 25 '/u02/oradata/&TARGET_SID/redo/log05.ora' size 1073741824;
alter database add logfile thread 1 group 26 '/u02/oradata/&TARGET_SID/redo/log06.ora' size 1073741824;
alter database add logfile thread 1 group 27 '/u02/oradata/&TARGET_SID/redo/log07.ora' size 1073741824;
alter database add logfile thread 1 group 28 '/u02/oradata/&TARGET_SID/redo/log08.ora' size 1073741824;
alter database add logfile thread 1 group 29 '/u02/oradata/&TARGET_SID/redo/log09.ora' size 1073741824;
alter database add logfile thread 1 group 30 '/u02/oradata/&TARGET_SID/redo/log10.ora' size 1073741824;


