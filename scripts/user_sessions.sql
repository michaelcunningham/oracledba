
DECLARE
    TYPE db_ref_cur IS REF CURSOR;
    db_session_cur db_ref_cur;
    ipAddress VARCHAR2(100);
    vsql Clob ;
    mLoggingEnabled    NUMBER(5);
    mSId               NUMBER;
    mSqlId             VARCHAR2(13);
    mSerial            NUMBER;
    mPAddr             RAW(8);
    mUserName          VARCHAR2(30);
    mOsUserName        VARCHAR2(30);
    mSchemaName        VARCHAR2(30);
    mMachine           VARCHAR2(64);
    mProgram           VARCHAR2(48);
    mTerminal          VARCHAR2(30);
    mLogonTime         DATE;
    mPrevExecStartTime DATE;
    mSqlText           VARCHAR2(1000);
    mKillSessionCmd    VARCHAR2(200);
    mKillProcCmd       VARCHAR2(200) ;
    mInstanceName      VARCHAR2(16);
    mEnv               VARCHAR2(10) := 'PROD';
    mDatabaseRole      VARCHAR2(16);
BEGIN
        select INSTANCE_NAME
        INTO mInstanceName 
        from v$instance;
        
        dbms_output.put_line('Starting ' || mInstanceName || ' on ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
        select DATABASE_ROLE
        INTO mDatabaseRole
        from v$database;
        IF mDatabaseRole = 'PRIMARY'
        THEN
            
            IF length(mInstanceName) > 3
            THEN
               IF upper(substr(mInstanceName,0,3)) = 'DEV' OR
                  upper(substr(mInstanceName,0,1)) = 'D'
               THEN
                  mEnv := 'DEV';
               ELSIF upper(substr(mInstanceName,0,1)) = 'S'
               THEN
                  mEnv := 'STAGE';
               END IF;
            END IF;
            
            BEGIN
                EXECUTE IMMEDIATE 'SELECT IS_ENABLED FROM TAGGEDMETA.USER_SESSIONS_FILTER@TO_DBA_DATA
                                   WHERE TYPE = ''QUERY_LOGGING'' AND 
                                         ( ENVIRONMENT IS NULL OR ENVIRONMENT = :mEnv  OR ENVIRONMENT = ''ALL'')'
                INTO mLoggingEnabled
                USING mEnv;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                mLoggingEnabled := 0;
            END;
            DBMS_OUTPUT.PUT_LINE('Logging of all sessions: ' || mLoggingEnabled);
            vsql := 'SELECT    
                            sid,
                            serial#,                     
                            osuser,
                            username,
                            schemaname,
                            machine,
                            program,
                            logon_time,
                            prev_exec_start,PADDR,
                            v.sql_id as sql_id,
                            v.sql_text as sql_text,
                            ''alter system DISCONNECT session ''''''||sid||'',''||serial#||'''''' IMMEDIATE  ;'' as kill_sess_cmdi/*,
                            (select ''!kill -9 ''||spid from v$process where addr in (select paddr from v$session where sid in (vs.sid) )) kill_proc_cmd*/
                     FROM v$session vs LEFT JOIN v$sql v ON vs.sql_id = v.sql_id
                     where osuser != ''oracle'' ';
            for filter_cur in (SELECT text 
                               FROM TAGGEDMETA.USER_SESSIONS_FILTER@TO_DBA_DATA
                               WHERE (TYPE = 'QUERY_WHERE' OR TYPE = 'QUERY_ALL')  AND 
                                     ( ENVIRONMENT IS NULL OR ENVIRONMENT = mEnv  OR ENVIRONMENT = 'ALL') AND
                                     IS_ENABLED = 1)
            LOOP
                vsql := vsql || ' ' || filter_cur.text;
            END LOOP;

            DBMS_OUTPUT.PUT_LINE(vsql);           
 
            OPEN db_session_cur FOR vsql;
            LOOP
               FETCH db_session_cur INTO 
                                            mSId,
                                            mSerial,
                                            mOsUserName,
                                            mUserName,
                                            mSchemaName,
                                            mMachine,
                                            mProgram,                                        
                                            mLogonTime,
                                            mPrevExecStartTime,
                                            mPAddr,
                                            mSqlId,
                                            mSqlText,
                                            mKillSessionCmd;
                                            --mKillProcCmd;
               EXIT WHEN db_session_cur%NOTFOUND;
                BEGIN
                   ipAddress := utl_inaddr.get_host_address(mMachine);
                EXCEPTION
                    WHEN OTHERS THEN
                        ipAddress := mMachine;
                END;

                --DBMS_OUTPUT.PUT_LINE( mOsUserName || ' ' ||   mUserName || ' ' || mSchemaName || ' ' || mMachine || ' ' || mSqlText);
                IF  NOT REGEXP_LIKE(ipAddress,'^1[0-9]\.(([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){2}([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$')
                THEN
                    IF (upper(mOsUserName) = 'ROOT' and mEnv = 'DEV')
                    THEN
                       CONTINUE;
                    END IF;

                    INSERT INTO USER_SESSIONS_HISTORY@TO_DBA_DATA (SESSION_DATE, ENVIRONMENT, INSTANCE_NAME, 
                                                                   SID, SERIAL#, PADDR, USERNAME, SCHEMANAME, 
                                                                   OSUSER, MACHINE, IP_ADDRESS, PROGRAM, LOGON_TIME, PREV_EXEC_START,
                                                                   SQL_ID, SQL_TEXT, SESS_KILL_CMD, PROC_KILL_CMD)
                    VALUES(SYSDATE,mEnv, mInstanceName, mSId, mSerial, mPAddr, mUserName, mSchemaName,
                           mOsUserName, mMachine,ipAddress, mProgram,mLogonTime, mPrevExecStartTime,mSqlId, mSqlText,
                           mKillSessionCmd, NULL);
                ELSIF mLoggingEnabled = 1 OR 
                      upper(mSqlText) LIKE '%CREATE %' OR 
                      upper(mSqlText) LIKE '%DROP %' OR 
                      upper(mSqlText) LIKE '%ALTER %' OR
                      upper(mSqlText) LIKE '%TRUNCATE %' 
                THEN
                       --DBMS_OUTPUT.PUT_LINE('Found DDL: ' || mSqlText) ;                       
                       IF (mOsUserName = 'tomcat' and (mSqlId is null or mSqlText is null or lower(mSqlText) like 'select 1+1 from dual' )) OR
                          (mOsUserName = 'sqlr' and (mSqlId is null or mSqlText is null or lower(mSqlText) like 'select 1+1 from dual'))
                       THEN
                           continue;
                       END IF;
                       --DBMS_OUTPUT.PUT_LINE( mOsUserName || ' ' ||   mUserName || ' ' || mSchemaName || ' ' || mMachine || ' ' || mSqlText);
                       INSERT INTO USER_SESSIONS_HISTORY@TO_DBA_DATA (SESSION_DATE, ENVIRONMENT, INSTANCE_NAME, 
                                                                   SID, SERIAL#, PADDR, USERNAME, SCHEMANAME, 
                                                                   OSUSER, MACHINE, IP_ADDRESS, PROGRAM, LOGON_TIME, PREV_EXEC_START,
                                                                   SQL_ID, SQL_TEXT, SESS_KILL_CMD, PROC_KILL_CMD)
                    VALUES(SYSDATE,mEnv, mInstanceName, mSId, mSerial, mPAddr, mUserName, mSchemaName,
                           mOsUserName, mMachine,ipAddress, mProgram,mLogonTime, mPrevExecStartTime,mSqlId, mSqlText,
                           mKillSessionCmd, NULL);         
                END IF;        
            END LOOP;    
            COMMIT;
            close db_session_cur;
        ELSE
            dbms_output.put_line( mInstanceName || ' is ' || mDatabaseRole);
        END IF;
        dbms_output.put_line('Finished ' || mInstanceName || ' at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
EXCEPTION     
    WHEN OTHERS THEN
       dbms_output.put_line('Message: '||SQLERRM);      
END;
/
