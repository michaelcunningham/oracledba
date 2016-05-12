Rem
Rem $Header: rdbms/admin/preupgrd.sql /st_rdbms_12.1/2 2014/05/14 21:19:54 apfwkr Exp $
Rem
Rem preupgrd.sql
Rem
Rem Copyright (c) 2011, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      preupgrd.sql - Script used to load and execute the pre upgrade checks.
Rem
Rem    DESCRIPTION
Rem      Loads utluppkg.sql (defines the dbms_preup package) and then
Rem      makes calls to the pre-upgrade package functions to determine
Rem      the status of the to-be-upgraded database.
Rem
Rem      Accepts two optional arguments:
Rem
Rem      @preupgrd {TERMINAL|FILE} {TEXT|XML} 
Rem
Rem         TERMINAL = Output goes to the default output device
Rem         FILE     = Output goes to file defined by 
Rem                    either 
Rem         TEXT = Generate normal text output
Rem         XML  = Generate an XML document (for DBUA use)
Rem
Rem   For example, to have the text output go to the screen:
Rem
Rem     @preupgrd TERMINAL TEXT
Rem
Rem    NOTES
Rem      
Rem      Requires the utluppkg.sql be present in the same directory
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      05/14/14 - Backport cmlim_bug-18550292 from main
Rem    apfwkr      04/27/14 - Backport ewittenb_bug-17874647 from main
Rem    ewittenb    03/26/14 - bug-17874647: allow output to FILE if DB is READONLY
Rem    cmlim       03/06/14 - Bug 18550292: enable it to run in mult pdbs
Rem                           simultaneously
Rem                           plus: some cleanup + add comments to original code
Rem                           plus: add preupgrd start/end to registry$log
Rem			      plus: cleanup and add comments to original code
Rem                           plus: create a subdirectory for pdb output files
Rem    ewittenb    10/18/13 - Bug 14614756: PREUPGRD.SQL NOT ABLE TO GENERATE THE LOG 
Rem    cmlim       08/17/13 - cmlim_preupgrd_cdb_1: phase 1 - support cdbs and
Rem                           non-cdbs in 12102
Rem    jerrede     05/31/13 - Make Read Only Work
Rem    cmlim       05/06/13 - bug 16191893 - use dbms_session.reset_package
Rem                           instead of dbms_preup.reset_init_package
Rem    cmlim       03/22/13 - bug 16191893 - reset error/warning/informational
Rem                           count on reruns of preupgrade tool
Rem    bmccarth    08/08/12 - noverify, new output
Rem    bmccarth    05/30/12 - fix nvl syntax 14119666
Rem                         - clarify comments
Rem                         - Call output_prolog
Rem    bmccarth    03/28/12 - increase linesize to deal with buffer wrapping
Rem    bmccarth    12/12/11 - Pre Upgrade Check Driver Script
Rem    bmccarth    12/12/11 - Created
Rem


Rem The below code will prevent any prompting if the script is 
Rem invoked without any parameters.
Rem

SET FEEDBACK OFF
SET TERMOUT OFF   

COLUMN 1 NEW_VALUE  1
SELECT NULL "1" FROM SYS.DUAL WHERE ROWNUM = 0;
SELECT NVL('&&1', 'FILE') FROM SYS.DUAL;

COLUMN 2 NEW_VALUE  2
SELECT NULL "2" FROM SYS.DUAL WHERE ROWNUM = 0;
SELECT NVL('&&2', 'TEXT') FROM SYS.DUAL;
SET FEEDBACK ON
SET TERMOUT ON

SET SERVEROUTPUT ON FORMAT WRAPPED;
SET ECHO OFF FEEDBACK OFF PAGESIZE 0 LINESIZE 5000;


Rem Setup component script filename variables
VARIABLE nReadOnlyMode NUMBER
BEGIN
  :nReadOnlyMode := 0;
END;
/

Rem by default, let say the db connected to is a non-cdb (or con id of 0)
VARIABLE nDbConId NUMBER
BEGIN
  :nDbConId := 0;
END;
/

COLUMN preupgrd_name NEW_VALUE preupgrd_file NOPRINT;
VARIABLE preupgrdinst_name VARCHAR2(256)                   
COLUMN :preupgrdinst_name NEW_VALUE preupgrdinst_file NOPRINT
Rem
Rem Hold commands used to create log directories on various OSes.
Rem 'exit' is the No-op command on all supported OSes, so this is a safe default.
Rem
VARIABLE osCreateDirCmd VARCHAR2(4000)
VARIABLE osCreateDirCmd2 VARCHAR2(4000)
VARIABLE osCreateDirCmd3 VARCHAR2(4000)

Rem
Rem set to true at begin of preupgrade tool.
Rem need consistent behavior whether the tool is run manually or via catcon.
Rem
DECLARE
  e_noOptionFound EXCEPTION;  -- ORA-2248: invalid option for ALTER SESSION
  PRAGMA exception_init(e_noOptionFound, -2248);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'alter session set "_ORACLE_SCRIPT" = TRUE';
  EXCEPTION
    WHEN e_noOptionFound THEN null;
  END;
END;
/

Rem
Rem create a sub-directory 'pdbfiles' only if running preupgrade in a pdb
Rem
DECLARE
  conId NUMBER := 0;
  e_invUserEnvParam EXCEPTION;  -- ORA-2003: invalid USERENV parameter
  PRAGMA exception_init(e_invUserEnvParam, -2003);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE
      'select SYS_CONTEXT(''USERENV'', ''CON_ID'') from sys.dual'
      into conId;
  EXCEPTION
    WHEN e_invUserEnvParam THEN conId := 0;
  END;

  -- store conId
  :nDbConId := conId;
END;
/

DECLARE
  tmp_varchar1    VARCHAR2(512);
  dbms_preup_loaded VARCHAR2(10);
  useDir          VARCHAR2(4000);
  baseDir         VARCHAR2(4000);
  homeDir         VARCHAR2(4000);
  rdbmsLogDir     VARCHAR2(4000);
  logDir          VARCHAR2(4000);
  pdbLogDir       VARCHAR2(4000);  -- sub-dir for pdb preupgrade output files
  db_platform     v$database.platform_name%TYPE;
  uniqueName      VARCHAR2(100);
BEGIN

  EXECUTE IMMEDIATE 'SELECT open_mode FROM sys.v$database' INTO tmp_varchar1;
  IF SUBSTR(tmp_varchar1,1,9) = 'READ ONLY' THEN
     BEGIN
       BEGIN
         -- if the DB is in READ ONLY mode, then we need for it to have already loaded DBMS_PREUP
         -- because READ ONLY mode prevents loading DBMS_PREUP now.
         EXECUTE IMMEDIATE 'SELECT object_name FROM sys.all_objects ' ||
                             'WHERE UPPER(object_type)=''PACKAGE'' and ' ||
                                    'object_name=''DBMS_PREUP'' and ' ||
                                    'owner=''SYS'' '
                            INTO dbms_preup_loaded;
       EXCEPTION WHEN NO_DATA_FOUND THEN
         dbms_output.put_line ('Error: Pre-Upgrade Package utluppkg.sql');
         dbms_output.put_line ('must be pre-loaded into the database before' );
         dbms_output.put_line ('you set the database to Read Only mode.');
         dbms_output.put_line ('That package must be loaded from the');
         dbms_output.put_line ('Oracle Home to which you are upgrading.');
       END;

       :preupgrdinst_name := '?/rdbms/admin/nothing.sql';
       :nReadOnlyMode := 1;

       -- 'exit' is the No-op command on all supported OSes
       :osCreateDirCmd := 'exit';
       :osCreateDirCmd2 := 'exit';
       :osCreateDirCmd3 := 'exit';
      END;
  ELSE

     --
     --    figure out where logfiles should go and prepare to create DIR if needed.
     --
     EXECUTE IMMEDIATE 'SELECT platform_name
             FROM v$database'
             INTO db_platform;



     EXECUTE IMMEDIATE 'SELECT value FROM v$parameter where '
             || 'name=''db_unique_name'''
             INTO uniqueName;

     DBMS_SYSTEM.GET_ENV('ORACLE_BASE', baseDir);
     DBMS_SYSTEM.GET_ENV('ORACLE_HOME', homeDir);

     IF baseDir IS NOT NULL THEN
       useDir := baseDir;
     ELSE
       useDir := homeDir;
     END IF;

     IF INSTR(db_platform, 'WINDOWS') != 0 THEN
         -- Windows, use '\'
         useDir := RTRIM(useDir, '\');  -- Remove any trailing slashes
         logDir := dbms_assert.enquote_literal(
                   useDir
                   || '\cfgtoollogs\'  
                   || uniqueName
                   || '\preupgrade\');
         rdbmsLogDir := homeDir || '\rdbms\log\';
         pdbLogDir := dbms_assert.enquote_literal(
                   useDir
                   || '\cfgtoollogs\'  
                   || uniqueName
                   || '\preupgrade\pdbfiles\');
         :osCreateDirCmd := 'mkdir ' || logDir;
         :osCreateDirCmd2 := 'mkdir ' || rdbmsLogDir;
         :osCreateDirCmd3 := 'mkdir ' || pdbLogDir;

     ELSIF INSTR(db_platform, 'VMS') != 0 THEN
         -- VMS, use [] and .
         logDir := dbms_assert.enquote_literal (REPLACE (
                   useDir
                   || '[cfgtoollogs.' 
                   ||  uniqueName
                   || '.preupgrade]', '][', '.'));
         rdbmsLogDir := REPLACE(homeDir || '[rdbms.log]', '][', '.');
         pdbLogDir := dbms_assert.enquote_literal (REPLACE (
                   useDir
                   || '[cfgtoollogs.' 
                   ||  uniqueName
                   || '.preupgrade'
                   || '.pdbfiles]', '][', '.'));
         :osCreateDirCmd := 'create/dir ' || logDir;
         :osCreateDirCmd2 := 'create/dir ' || rdbmsLogDir;
         :osCreateDirCmd3 := 'create/dir ' || pdbLogDir;

     ELSE 
         -- Unix and z/OS, '/'
         useDir := RTRIM(useDir, '/');  -- Remove any trailing slashes
         logDir := dbms_assert.enquote_literal(
                   useDir
                   || '/cfgtoollogs/' 
                   || uniqueName
                   || '/preupgrade/');
         rdbmsLogDir := homeDir || '/rdbms/log/';
         pdbLogDir := dbms_assert.enquote_literal(
                   useDir
                   || '/cfgtoollogs/' 
                   || uniqueName
                   || '/preupgrade/pdbfiles/');
         :osCreateDirCmd := 'mkdir -p ' || logDir;
         :osCreateDirCmd2 := 'mkdir -p ' || rdbmsLogDir;
         :osCreateDirCmd3 := 'mkdir -p ' || pdbLogDir;

     END IF;

     :preupgrdinst_name := 'utluppkg.sql';
     :nReadOnlyMode := 0;

     -- If db is non-cdb (con id 0) or root (con id 1), then don't create
     -- subdirectory pdbfiles.
     IF :nDbConId <= 1 THEN
         :osCreateDirCmd3 := 'exit';
     END IF;
  END IF;

END;
/  

Rem
Rem Create log directories if needed while we can use HOST cmd.
Rem
COLUMN create_cmd NEW_VALUE create_cmd NOPRINT
SELECT :osCreateDirCmd AS create_cmd FROM dual;
HOST &create_cmd
SELECT :osCreateDirCmd2 AS create_cmd FROM dual;
HOST &create_cmd
SELECT :osCreateDirCmd3 AS create_cmd FROM dual;
HOST &create_cmd

BEGIN
    IF :nReadOnlyMode = 0 THEN
      dbms_output.put_line ('Loading Pre-Upgrade Package...');
    END IF;
END;
/

Rem
Rem Run this from the current area as we will be asking customers to 
Rem bring both the package and this driving script from the new 
Rem software installation.
Rem
SELECT :preupgrdinst_name FROM SYS.DUAL;
@@&preupgrdinst_file


Rem
Rem Supressed parameter replacement output 
Rem 
SET VERIFY OFF

DECLARE
 stat          NUMBER;
 output_target VARCHAR2(10) := 'FILE';
 output_type   VARCHAR2(10) := 'TEXT';

BEGIN
  --
  -- Allow optional parameter to script 
  -- 
  -- Known Values (all others ignored):
  --
  --    Value         Action
  --
  --    FILE     - Output goes into log file (Default)
  --    TERMINAL - Output goes to terminal (or redirected output)
  --    - no arg - Same as FILE
  --
  --    TEXT     - Output TEXT (not XML) (Default)
  --    XML      - Generate an XML document
  --    - no arg - Same as TEXT
  --

  IF UPPER('&&1') = 'TERMINAL' THEN
    output_target := 'TERMINAL';
  ELSIF ( '&&1'IS NULL OR UPPER('&&1') = 'FILE') THEN 
    output_target := 'FILE';
  END IF;

  IF UPPER('&&2') = 'XML' THEN
    output_type := 'XML';
  ELSIF ( '&&2'IS NULL OR UPPER('&&2') = 'TEXT') THEN 
    output_type := 'TEXT';
  END IF;

  -- add entry into registry$log that preupgrade tool is going to run
  dbms_preup.begin_log_preupg_action;

  --
  -- Text or XML (from second argument, or defaulted)
  -- set output type to 'TEXT' or 'XML' before opening the file
  --
  dbms_preup.set_output_type(output_type);


  IF output_target = 'FILE' THEN
    IF output_type = 'XML' THEN
      -- 
      -- directory object PREUPG_OUTPUT_DIR is created by DBUA on the source
      -- (to be upgraded) database
      --
      dbms_preup.set_output_file('PREUPG_OUTPUT_DIR', 'upgrade.xml');
    ELSE
      --
      -- Text output, with scripts
      --
      dbms_preup.set_output_file(TRUE);
      dbms_preup.set_fixup_scripts(TRUE);  -- name was previously set_scripts.
                                           -- changed it to be more meaningful.
    END IF;
  ELSE
    --
    -- we will need a big buffer
    --
    DBMS_OUTPUT.ENABLE(900000);
  END IF;

  IF output_type = 'XML' THEN
    dbms_preup.start_xml_document;
  END IF;

  -- Generate information about the database

  dbms_preup.output_summary;
  dbms_preup.output_initparams;
  dbms_preup.output_components;
  dbms_preup.output_resources;

  -- Execute all the pre-upgrade checks

  stat :=  dbms_preup.run_all_checks;

  dbms_preup.output_preup_checks;

  --
  -- Get the Recommendations out
  --
  dbms_preup.output_recommendations;

  --
  -- Summary
  --
  dbms_preup.output_prolog;

  -- >> BEGIN: OUTPUT TO FILE, whether text or xml
  IF output_target = 'FILE' THEN

    IF output_type = 'XML' THEN  -- for DBUA
      dbms_preup.end_xml_document;

    ELSIF output_type = 'TEXT' THEN  -- not DBUA
      --
      -- Call routine to dump out a summary 
      --
      dbms_preup.output_check_summary;
  
      dbms_preup.set_fixup_scripts    (FALSE);
  
      -- concatentate output to final destination file(s) if container is pdb
      -- note: not done for DBUA/XML file type
      IF :nDbConId > 1 THEN
        dbms_preup.concat_pdb_file;
      END IF;
  
      dbms_preup.set_output_file(FALSE);   -- close preupgrade.log
  
      dbms_preup.output_results_location; -- list location of text results
    END IF;

    dbms_preup.close_file;

  END IF;
  -- >> END: OUTPUT TO FILE 

END;
/ 

-- Finishing steps
execute      dbms_preup.end_preupgrd;

-- DBMS_SESSION.RESET_PACKAGE to be called last
-- bug 16191893 : this will deinstatiate the package so that global variables
-- (e.g., error msg count) on next run of preupgrade tool will be reset.
-- This call is for when reruns are executed in same sqlplus session.
execute dbms_session.reset_package;

-- reset to false on exit of preupgrade tool.
DECLARE
  e_noOptionFound EXCEPTION;  -- ORA-2248: invalid option for ALTER SESSION
  PRAGMA exception_init(e_noOptionFound, -2248);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'alter session set "_ORACLE_SCRIPT" = FALSE';
  EXCEPTION
    WHEN e_noOptionFound THEN null;
  END;
END;
/

Rem
Rem Back on.
Rem
SET VERIFY ON
