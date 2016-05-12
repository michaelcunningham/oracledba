
define TARGET_SID='SPDB07'

alter database drop standby logfile group 21;
alter database drop standby logfile group 22;
alter database drop standby logfile group 23;
alter database drop standby logfile group 24;
alter database drop standby logfile group 25;
alter database drop standby logfile group 26;
alter database drop standby logfile group 27;
alter database drop standby logfile group 28;
alter database drop standby logfile group 29;
alter database drop standby logfile group 30;
alter database drop standby logfile group 31;
alter database add standby logfile thread 1 group 21 '/u02/oradata/&TARGET_SID/redo/stby_log21.ora' size 1073741824;
alter database add standby logfile thread 1 group 22 '/u02/oradata/&TARGET_SID/redo/stby_log22.ora' size 1073741824;
alter database add standby logfile thread 1 group 23 '/u02/oradata/&TARGET_SID/redo/stby_log23.ora' size 1073741824;
alter database add standby logfile thread 1 group 24 '/u02/oradata/&TARGET_SID/redo/stby_log24.ora' size 1073741824;
alter database add standby logfile thread 1 group 25 '/u02/oradata/&TARGET_SID/redo/stby_log25.ora' size 1073741824;
alter database add standby logfile thread 1 group 26 '/u02/oradata/&TARGET_SID/redo/stby_log26.ora' size 1073741824;
alter database add standby logfile thread 1 group 27 '/u02/oradata/&TARGET_SID/redo/stby_log27.ora' size 1073741824;
alter database add standby logfile thread 1 group 28 '/u02/oradata/&TARGET_SID/redo/stby_log28.ora' size 1073741824;
alter database add standby logfile thread 1 group 29 '/u02/oradata/&TARGET_SID/redo/stby_log29.ora' size 1073741824;
alter database add standby logfile thread 1 group 30 '/u02/oradata/&TARGET_SID/redo/stby_log30.ora' size 1073741824;
alter database add standby logfile thread 1 group 31 '/u02/oradata/&TARGET_SID/redo/stby_log31.ora' size 1073741824;




