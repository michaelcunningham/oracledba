SET FEEDBACK OFF
SET LINESIZE 250
SET SERVEROUTPUT ON


DECLARE
-- Variables declared
P_OTAB DBMS_STATS.OBJECTTAB;
MCOUNT NUMBER := 0;
P_VERSION VARCHAR2(10);
-- Cursor defined
CURSOR c1
IS
SELECT distinct schema
FROM dba_registry
ORDER by 1;


-- Beginning of the anonymous block
BEGIN
-- Verifying version from v$instance
SELECT version INTO p_version FROM v$instance;
DBMS_OUTPUT.PUT_LINE(chr(13));
-- Defining Loop 1 for listing schema which have stale stats
FOR x in c1 
LOOP
 DBMS_STATS.GATHER_SCHEMA_STATS(OWNNAME=>x.schema,OPTIONS=>'LIST AUTO',OBJLIST=>p_otab);


-- Defining Loop 2 to find number of objects containing stale stats
 FOR i in 1 .. p_otab.count
 LOOP
  IF p_otab(i).objname NOT LIKE 'SYS_%' 
   AND p_otab(i).objname NOT IN ('CLU$','COL_USAGE$','FET$','INDPART$',
          'MON_MODS$','TABPART$','HISTGRM$',
          'MON_MODS_ALL$',
          'HIST_HEAD$','IN $','TAB$',
          'WRI$_OPTSTAT_OPR','PUIU$DATA',
          'XDB$NLOCKS_CHILD_NAME_IDX',
          'XDB$NLOCKS_PARENT_OID_IDX',
          'XDB$NLOCKS_RAWTOKEN_IDX', 'XDB$SCHEMA_URL',
          'XDBHI_IDX', 'XDB_PK_H_LINK')
  THEN
-- Incrementing count for each object found with statle stats
   mcount := mcount + 1;
  END IF;
-- End of Loop 2
 END LOOP;


-- Displays no stale statistics, if coun is 0
  IF mcount!=0 
   THEN
-- Displays Schema with stale stats if count is greater than 0
    DBMS_OUTPUT.PUT_LINE(chr(13));
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('-- '|| x.schema || ' schema contains stale statistics use the following to gather the statistics '||'--');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');
    
-- Displays Command to be executed if schema with stale statistics is found depending on the version.
  IF SUBSTR(p_version,1,5) in ('8.1.7','9.0.1','9.2.0') 
   THEN
    DBMS_OUTPUT.PUT_LINE(chr(13));
    DBMS_OUTPUT.PUT_LINE('EXEC DBMS_STATS.GATHER_SCHEMA_STATS('''||x.schema||''',OPTIONS=>'''||'GATHER'||''', ESTIMATE_PERCENT => DBMS_STATS.AUTO_SAMPLE_SIZE, METHOD_OPT => '''||'FOR ALL COLUMNS SIZE AUTO'||''', CASCADE => TRUE);');
  ELSIF SUBSTR(p_version,1,6) in ('10.1.0','10.2.0','11.1.0') 
   THEN
    DBMS_OUTPUT.PUT_LINE(chr(13));
    DBMS_OUTPUT.PUT_LINE('EXEC DBMS_STATS.GATHER_DICTIONARY_STATS('''||x.schema||''',OPTIONS=>'''||'GATHER'||''', ESTIMATE_PERCENT => DBMS_STATS.AUTO_SAMPLE_SIZE, METHOD_OPT => '''||'FOR ALL COLUMNS SIZE AUTO'||''', CASCADE => TRUE);');
  ELSE
    DBMS_OUTPUT.PUT_LINE(chr(13));
    DBMS_OUTPUT.PUT_LINE('Version is '||p_version);
  END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE('-- There are no stale statistics in '|| x.schema || ' schema.');
    DBMS_OUTPUT.PUT_LINE(chr(13));
  END IF;
-- Reset count to 0.
   mcount := 0;
-- End of Loop 1
END LOOP;
END;
/


SET FEEDBACK ON
