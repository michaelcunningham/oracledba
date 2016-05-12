-------------------------------------------------------------------------------
--  Script to describe information about the current session.
--
--  3.01 Jun 1999 - Broke out Database/Instance information. J Lopatosky
--  3.00 Dec 1998 - Combined previous versions (whoami73, whoami80) into this pl/sql
--                  program. J Lopatosky
--  2.01 May 1998 - Check for Restricted Mode.  J Lopatosky
--  2.00 Oct 1997 - Rewrote, using one sql with union statements and dummy
--                  column for sorting.  J Lopatosky
--  1.01 May 1997 - Modified for own settings. J Lopatosky
--  1.00 Original version by Rick Holberger, SDA, Inc. (ECO'97)
--

--  Set SQL*Plus environment
@@com_set.sql

select '&_O_VERSION' versions from dual;

DECLARE

@@com_declares.sql
@@com_routines.sql

-------------------------------------------------------------------------------
--  Session Information
-------------------------------------------------------------------------------
PROCEDURE display_username IS
BEGIN
  v_display_line := 'Username               = ' || USER;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_sid IS
BEGIN
  v_sql := 'SELECT sid'
        || '  INTO :v_sql_result'
        || '  FROM v$mystat';
  run_dynamic_sql(v_sql);
  v_display_line := 'Session ID (SID)       = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_session_connect_73 IS
BEGIN
  v_sql := 'SELECT TO_CHAR(logon_time,''Mon, DD YYYY HH24:MI:SS'')'
        || '  INTO :v_sql_result'
        || '  FROM v$session'
        || ' WHERE username = USER '
        || '   AND sid = (SELECT DISTINCT sid FROM v$mystat) ';
  run_dynamic_sql(v_sql);
  v_display_line := 'Session Connect        = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
--  Instance Information
-------------------------------------------------------------------------------
PROCEDURE display_inst_name IS
BEGIN
  v_sql := 'SELECT instance_name'
        || '  INTO :v_sql_result'
        || '  FROM v$instance';
  run_dynamic_sql(v_sql);
  v_display_line := 'Instance Name          = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_inst_start_73 IS
BEGIN
  v_sql := 'SELECT TO_CHAR(logon_time,''Mon, DD YYYY HH24:MI:SS'')'
        || '  INTO :v_sql_result'
        || '  FROM v$session'
        || ' WHERE sid=1';
  run_dynamic_sql(v_sql);
  v_display_line := 'Instance Started       = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_inst_start_80 IS
BEGIN
  v_sql := 'SELECT TO_CHAR(startup_time,''Mon, DD YYYY HH24:MI:SS'')'
        || '  INTO :v_sql_result'
        || '  FROM v$instance';
  run_dynamic_sql(v_sql);
  v_display_line := 'Instance Started       = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_inst_access_73 IS
BEGIN
  v_sql := 'SELECT DECODE(value,'
        || '         0,''Normal'','
        || '         4096,''Restricted Session Enabled'','
        || '         ''???'')'
        || '  INTO :v_sql_result'
        || '  FROM v$instance'
        || ' WHERE key = ''RESTRICTED MODE'' ';
  run_dynamic_sql(v_sql);
  v_display_line := 'Instance Access Mode   = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_inst_access_80 IS
BEGIN
  v_sql := 'SELECT logins'
        || '  INTO :v_sql_result'
        || '  FROM v$instance';
  run_dynamic_sql(v_sql);
  v_display_line := 'Instance Access Mode   = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_inst_status_80 IS
BEGIN
  v_sql := 'SELECT status'
        || '  INTO :v_sql_result'
        || '  FROM v$instance';
  run_dynamic_sql(v_sql);
  v_display_line := 'Instance Status        = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
--  Database Information
-------------------------------------------------------------------------------
PROCEDURE display_db_name IS
BEGIN
  v_sql := 'SELECT name'
        || '  INTO :v_sql_result'
        || '  FROM v$database';
  run_dynamic_sql(v_sql);
  v_display_line := 'Database Name          = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_db_arch_mode IS
BEGIN
  v_sql := 'SELECT log_mode'
        || '  INTO :v_sql_result'
        || '  FROM v$database';
  run_dynamic_sql(v_sql);
  v_display_line := 'Database Mode          = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_db_created IS
BEGIN
  v_sql := 'SELECT TO_CHAR(created,''Mon, DD YYYY HH24:MI:SS'')'
        || '  INTO :v_sql_result'
        || '  FROM v$database';
  run_dynamic_sql(v_sql);
  v_display_line := 'Database Created       = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
--  Host Information
-------------------------------------------------------------------------------
PROCEDURE display_host IS
BEGIN
  v_sql := 'SELECT machine'
        || '  INTO :v_sql_result'
        || '  FROM v$session'
        || ' WHERE rownum = 1';
  run_dynamic_sql(v_sql);
  v_display_line := 'Host                   = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_host_date IS
BEGIN
  v_sql := 'SELECT TO_CHAR(sysdate,''Mon, DD YYYY HH24:MI:SS'')'
        || '  INTO :v_sql_result_date'
        || '  FROM sys.dual';
  run_dynamic_sql(v_sql);
  v_display_line := 'Host Date              = ' || v_sql_result;
  display_line(v_display_line);
END ;

-------------------------------------------------------------------------------
--  Display information for unknown database version.
PROCEDURE display_oraxx_information IS
BEGIN
  display_username;
  display_db_name;
END ;

-------------------------------------------------------------------------------
--  Display information for Oracle 7.3
PROCEDURE display_ora73_information IS
BEGIN
  display_username;
  display_sid;
  display_session_connect_73;

  display_line;

  display_inst_access_73;
  display_inst_start_73;
  
  display_line;

  display_db_name;
  display_db_arch_mode;

  display_line;

  display_host;
  display_host_date;
END ;

-------------------------------------------------------------------------------
--  Display information for Oracle 8.0
PROCEDURE display_ora80_information IS
BEGIN
  display_username;
  display_sid;
  display_session_connect_73;

  display_line;

  display_inst_name;
  display_inst_status_80;
  display_inst_access_80;
  display_inst_start_80;
  
  display_line;

  display_db_name;
  display_db_arch_mode;
  display_db_created;

  display_line;

  display_host;
  display_host_date;
END ;

-------------------------------------------------------------------------------
--  Display information for Oracle 8.1
PROCEDURE display_ora81_information IS
BEGIN
  display_username;
  display_sid;
  display_session_connect_73;

  display_line;

  display_inst_name;
  display_inst_status_80;
  display_inst_access_80;
  display_inst_start_73;
  
  display_line;

  display_db_name;
  display_db_arch_mode;
  display_db_created;

  display_line;

  display_host;
  display_host_date;
END ;

-------------------------------------------------------------------------------
--  Main Logic

BEGIN

  capture_time;

-- Get version information from database
  v_db_version := check_oracle_version;

-- Test for Oracle Version.
  IF v_db_version LIKE '7.3%' THEN
    display_ora73_information;
  ELSIF v_db_version LIKE '8.0%' THEN
    display_ora80_information;
  ELSIF v_db_version LIKE '8.1%' THEN
    display_ora81_information;
  ELSIF v_db_version LIKE '%10%' THEN
    display_ora81_information;
  ELSE
    display_oraxx_information;
  END IF;
  display_line;

  capture_time;
  display_elapsed_time;

END;

/

--  Reset SQL*Plus environment
@com_reset.sql
set timing off
