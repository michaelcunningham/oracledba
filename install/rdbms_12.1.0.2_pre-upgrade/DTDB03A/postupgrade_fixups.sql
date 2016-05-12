REM Post Upgrade Script Generated on: 2016-03-07 16:21:28 
REM Generated by Version: 12.1.0.2 Build: 008
SET ECHO OFF SERVEROUTPUT ON FORMAT WRAPPED TAB OFF LINESIZE 750;
 
DECLARE
con_name varchar2(40);
 
BEGIN 
execute immediate 
  'select dbms_preup.get_con_name from sys.dual' into con_name;
 
IF con_name = 'DTDB03' THEN
 
BEGIN
dbms_output.put_line ('Post Upgrade Fixup Script Generated on 2016-03-07 16:21:28  Version: 12.1.0.2 Build: 008');
dbms_output.put_line ('Beginning Post-Upgrade Fixups...');
END;
 
BEGIN
dbms_preup.clear_run_flag(FALSE);
END;
 
BEGIN
-- *****************  Fixup Details ***********************************
-- Name:        INVALID_OBJECTS_EXIST
-- Description: Check for invalid objects
-- Severity:    Warning
-- Action:      ^^^ MANUAL ACTION REQUIRED ^^^
-- Fix Summary: 
--     Invalid objects are displayed and must be reviewed.

dbms_preup.run_fixup_and_report('INVALID_OBJECTS_EXIST');
END;
 
BEGIN
-- *****************  Fixup Details ***********************************
-- Name:        OLD_TIME_ZONES_EXIST
-- Description: Check for use of older timezone data file
-- Severity:    Informational
-- Action:      ^^^ MANUAL ACTION REQUIRED ^^^
-- Fix Summary: 
--     Update the timezone using the DBMS_DST package after upgrade is complete.

dbms_preup.run_fixup_and_report('OLD_TIME_ZONES_EXIST');
END;
 
BEGIN
-- *****************  Fixup Details ***********************************
-- Name:        NOT_UPG_BY_STD_UPGRD
-- Description: Identify existing components that will NOT be upgraded
-- Severity:    Informational
-- Action:      ^^^ MANUAL ACTION REQUIRED ^^^
-- Fix Summary: 
--     This fixup does not perform any action.

dbms_preup.run_fixup_and_report('NOT_UPG_BY_STD_UPGRD');
END;
 
BEGIN
dbms_output.put_line ('');
dbms_output.put_line ('**********************************************************************');
dbms_output.put_line ('                     [Post-Upgrade Recommendations]');
dbms_output.put_line ('**********************************************************************');
dbms_output.put_line ('');
END;
 
BEGIN
dbms_output.put_line ('                        *****************************************');
dbms_output.put_line ('                        ******** Fixed Object Statistics ********');
dbms_output.put_line ('                        *****************************************');
dbms_output.put_line ('');
dbms_output.put_line ('Please create stats on fixed objects two weeks');
dbms_output.put_line ('after the upgrade using the command:');
dbms_output.put_line ('   EXECUTE DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;');
dbms_output.put_line ('');
dbms_output.put_line ('^^^ MANUAL ACTION SUGGESTED ^^^');
dbms_output.put_line ('');
END;
 
BEGIN dbms_preup.fixup_summary(FALSE); END;
 
BEGIN
dbms_output.put_line ('*************** Post Upgrade Fixup Script Complete ********************');
END;
 
END IF;
 
END;
/
-- Post Upgrade Script Closed At: 2016-03-07 16:21:33 
REM __________________________________________________________________________
 
