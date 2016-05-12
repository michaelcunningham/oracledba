REM Pre-Upgrade Script Generated on: 2016-03-07 15:55:30 
REM Generated by Version: 12.1.0.2 Build: 008
SET ECHO OFF SERVEROUTPUT ON FORMAT WRAPPED TAB OFF LINESIZE 750;
 
DECLARE
con_name varchar2(40);
 
BEGIN 
execute immediate 
  'select dbms_preup.get_con_name from sys.dual' into con_name;
 
IF con_name = 'DEVPDB02' THEN
 
BEGIN
dbms_output.put_line ('Pre-Upgrade Fixup Script Generated on 2016-03-07 15:55:30  Version: 12.1.0.2 Build: 008');
dbms_output.put_line ('Beginning Pre-Upgrade Fixups...');
dbms_output.put_line ('Executing in container DEVPDB02');
END;
 
BEGIN
dbms_preup.clear_run_flag(TRUE);
END;
 
BEGIN
-- *****************  Fixup Details ***********************************
-- Name:        AMD_EXISTS
-- Description: Check to see if AMD is present in the database
-- Severity:    Informational
-- Action:      ^^^ MANUAL ACTION REQUIRED ^^^
-- Fix Summary: 
--     Manually execute ORACLE_HOME/oraolap/admin/catnoamd.sql script to remove OLAP.

dbms_preup.run_fixup_and_report('AMD_EXISTS');
END;
 
BEGIN
-- *****************  Fixup Details ***********************************
-- Name:        APEX_UPGRADE_MSG
-- Description: Check that APEX will need to be upgraded.
-- Severity:    Informational
-- Action:      ^^^ MANUAL ACTION REQUIRED ^^^
-- Fix Summary: 
--     Oracle Application Express can be manually upgraded prior to database upgrade.

dbms_preup.run_fixup_and_report('APEX_UPGRADE_MSG');
END;
 
BEGIN
dbms_output.put_line ('');
dbms_output.put_line ('**********************************************************************');
dbms_output.put_line ('                      [Pre-Upgrade Recommendations]');
dbms_output.put_line ('**********************************************************************');
dbms_output.put_line ('');
END;
 
BEGIN
dbms_output.put_line ('                        *****************************************');
dbms_output.put_line ('                        ********* Dictionary Statistics *********');
dbms_output.put_line ('                        *****************************************');
dbms_output.put_line ('');
dbms_output.put_line ('Please gather dictionary statistics 24 hours prior to');
dbms_output.put_line ('upgrading the database.');
dbms_output.put_line ('To gather dictionary statistics execute the following command');
dbms_output.put_line ('while connected as SYSDBA:');
dbms_output.put_line ('    EXECUTE dbms_stats.gather_dictionary_stats;');
dbms_output.put_line ('');
dbms_output.put_line ('^^^ MANUAL ACTION SUGGESTED ^^^');
dbms_output.put_line ('');
END;
 
BEGIN dbms_preup.fixup_summary(TRUE); END;
 
BEGIN
dbms_output.put_line ('**************** Pre-Upgrade Fixup Script Complete *********************');
END;
 
END IF;
 
END;
/
REM Pre-Upgrade Script Closed At: 2016-03-07 15:55:35 
REM __________________________________________________________________________
 
