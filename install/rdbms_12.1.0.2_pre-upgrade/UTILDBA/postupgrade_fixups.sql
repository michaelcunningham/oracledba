REM Post Upgrade Script Generated on: 2016-02-29 15:07:54 
REM Generated by Version: 12.1.0.2 Build: 008
SET ECHO OFF SERVEROUTPUT ON FORMAT WRAPPED TAB OFF LINESIZE 750;
 
DECLARE
con_name varchar2(40);
 
BEGIN 
execute immediate 
  'select dbms_preup.get_con_name from sys.dual' into con_name;
 
IF con_name = 'UTILDB' THEN
 
BEGIN
dbms_output.put_line ('Post Upgrade Fixup Script Generated on 2016-02-29 15:07:54  Version: 12.1.0.2 Build: 008');
dbms_output.put_line ('Beginning Post-Upgrade Fixups...');
END;
 
BEGIN
dbms_preup.clear_run_flag(FALSE);
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
-- Post Upgrade Script Closed At: 2016-02-29 15:07:55 
REM __________________________________________________________________________
 
