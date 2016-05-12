set echo on time on timing on
set heading on
set serveroutput on
spool /mnt/dba/projects/DBA-6082/logs/sora11_p24_p31_rename_objects.log

DECLARE
    TYPE ref_type_cur IS REF CURSOR;
    mDbaObjectCur ref_type_cur;
    mTableName VARCHAR2(100):= null;
    mObjectName VARCHAR2(100):= null;
    mRenamedObjectName VARCHAR2(100):= null;
    mObjectType VARCHAR2(100);
    mStartPartion NUMBER(3) := 24;
    mEndPartition NUMBER(3) := 31;
    mSaveHistoryTable VARCHAR2(1) := 'Y';
    mSql VARCHAR2(4000);
    mRollbackSql VARCHAR2(4000) := '';
    mRespStr VARCHAR2(201) := 'SUCCESS';
    mRespCode NUMBER(5) := 0;
    mClobSql Clob;
    mHistoryTable VARCHAR2(30) := 'DB_SCHEMA_OBJ_TO_DROP';
    mNamePrefix VARCHAR2(10);
    mIndex NUMBER(3) := 0;
    mInsertSQl VARCHAR2(4000) :='';
BEGIN
    BEGIN
        SELECT object_name, object_type
        INTO mTableName, mObjectType
        FROM dba_objects
        WHERE object_name = mHistoryTable and
              OBJECT_TYPE = 'TABLE' AND
              OWNER = 'TAG';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(mHistoryTable || ' does not exists');

            DBMS_OUTPUT.PUT_LINE(mHistoryTable || ' table is created');
            execute immediate 'create table ' || mHistoryTable || '  (
                                OBJECT_NAME VARCHAR2(128) NOT NULL,
                                OBJECT_TYPE VARCHAR2(128) NOT NULL,
                                RENAMED_OBJ_NAME VARCHAR2(128),
                                SQL_STMT VARCHAR2(4000),
                                ROLLBACK_SQL_STMT VARCHAR2(4000),
                                STATUS_CODE NUMBER(10),
                                STATUS VARCHAR2 (201),
                                DATE_ADDED DATE DEFAULT SYSDATE
                            )';
     END;
     /**** Building object query *****/
    mClobSql := 'SELECT object_name, OBJECT_TYPE
             FROM dba_objects
             WHERE owner = ''TAG'' AND
                   (object_type = ''TABLE'' OR
                    --object_type = ''TRIGGER'' OR
                    object_type = ''VIEW'' OR
                    object_type = ''SEQUENCE'') AND
           (
             ';
    FOR pkey in mStartPartion..mEndPartition
    LOOP
        mClobSql := mClobSql 
                         || '((object_name LIKE ''%_P' || pkey || ''' ESCAPE ''\'' OR 
                              object_name LIKE ''%_P' || pkey || '\_%'' ESCAPE ''\'' )AND 
                              object_name NOT LIKE ''D\_%P' || pkey || '%'' ESCAPE ''\'')';
        IF pkey < mEndPartition
        THEN
            mClobSql := mClobSql || ' OR ';
        END IF;
    END LOOP;
    mClobSql := mClobSql || ' ) ' ||
                ' ORDER BY OBJECT_TYPE ASC, OBJECT_NAME ASC';
    DBMS_OUTPUT.PUT_LINE(mClobSql) ;

    mInsertSQl := 'INSERT INTO ' || mHistoryTable || ' (OBJECT_NAME, OBJECT_TYPE, RENAMED_OBJ_NAME, SQL_STMT, ROLLBACK_SQL_STMT,  STATUS_CODE, STATUS)
                          VALUES (:mObjectName, :mObjectType, :mRenamedObjectName, :mSql, :mRollbackSql, :mRespCode, :mRespStr)';
    DBMS_OUTPUT.PUT_LINE(mInsertSQl);

    OPEN mDbaObjectCur FOR mClobSql;
    LOOP
        FETCH mDbaObjectCur INTO mObjectName,mObjectType;
 EXIT WHEN mDbaObjectCur%NOTFOUND;
        mSql:= '';
        mRespCode := 0;
        mRollbackSql := '';
        mIndex := mIndex + 1;
        IF mIndex > 99
        THEN
           mIndex := 1;
        END IF;

        mNamePrefix := 'D_' || mIndex || '_';

        IF upper(mObjectType) = 'TABLE'
        THEN
           mRenamedObjectName := mNamePrefix || mObjectName;
           IF LENGTH( mRenamedObjectName ) > 30
           THEN
              DBMS_OUTPUT.PUT_LINE('Table name is to big. Table: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
              mRenamedObjectName := mNamePrefix || SUBSTR(mObjectName,(length(mNamePrefix) + 1));
              DBMS_OUTPUT.PUT_LINE('Table name truncated. Table: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
           END IF;
              mSql := 'ALTER TABLE ' || mObjectName || ' RENAME TO ' || mRenamedObjectName ;
              mRollbackSql := 'ALTER TABLE ' || mRenamedObjectName || ' RENAME TO ' || mObjectName  || ';';
              DBMS_OUTPUT.PUT_LINE('Renamed: ' || mSql);
              DBMS_OUTPUT.PUT_LINE('Rollback: ' ||  mRollbackSql);
               BEGIN
                      EXECUTE IMMEDIATE mSql;
                      mRespStr := 'Renamed';
                      NULL;
               EXCEPTION
                    WHEN OTHERS THEN
                        mRespCode := SQLCODE;
                        mRespStr :=  SUBSTR(SQLERRM, 1, 200);
                        DBMS_OUTPUT.PUT_LINE(mObjectName || ' ' || SUBSTR(SQLERRM, 1, 200));
               END;
               mSql := mSql || ';';
        ELSIF upper(mObjectType) = 'TRIGGER' 
        THEN
            mRenamedObjectName := mNamePrefix || mObjectName;
            IF LENGTH(mRenamedObjectName ) > 30
           THEN
              DBMS_OUTPUT.PUT_LINE(mObjectType || ' name is to big. Old: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
              mRenamedObjectName := mNamePrefix || SUBSTR(mObjectName,(length(mNamePrefix) + 1));
              DBMS_OUTPUT.PUT_LINE(mObjectType || ' has been truncated. Old: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
           END IF;
              mSql := 'ALTER TRIGGER ' || mObjectName || ' RENAME TO ' || mRenamedObjectName;
              mRollbackSql := 'ALTER TRIGGER ' || mRenamedObjectName || ' RENAME TO ' || mObjectName  || ';';
              DBMS_OUTPUT.PUT_LINE('Renamed: ' || mSql);
              DBMS_OUTPUT.PUT_LINE('Rollback: ' ||  mRollbackSql);
               BEGIN
                      EXECUTE IMMEDIATE mSql;
                      NULL;
                      mRespStr := 'Renamed';
               EXCEPTION
                    WHEN OTHERS THEN
                        mRespCode := SQLCODE;
                        mRespStr :=  SUBSTR(SQLERRM, 1, 200);
                        DBMS_OUTPUT.PUT_LINE(mObjectName || ' ' || SUBSTR(SQLERRM, 1, 200));
               END;
               mSql := mSql || ';';
        ELSIF upper(mObjectType) = 'SEQUENCE' OR
              upper(mObjectType) = 'VIEW'
        THEN
            mRenamedObjectName := mNamePrefix || mObjectName;
            IF LENGTH(mRenamedObjectName ) > 30
           THEN
              DBMS_OUTPUT.PUT_LINE(mObjectType || ' name is to big. Old: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
              mRenamedObjectName := mNamePrefix || SUBSTR(mObjectName,(length(mNamePrefix) + 1));
              DBMS_OUTPUT.PUT_LINE(mObjectType || ' has been truncated. Old: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
           END IF;
              mSql := 'RENAME ' || mObjectName || ' TO ' || mRenamedObjectName  ;
              mRollbackSql := 'RENAME ' || mRenamedObjectName || ' TO ' || mObjectName  || ';';
              DBMS_OUTPUT.PUT_LINE('Renamed: ' || mSql);
              DBMS_OUTPUT.PUT_LINE('Rollback: ' ||  mRollbackSql);
               BEGIN
                      EXECUTE IMMEDIATE mSql;
                      NULL;
                      mRespStr := 'Renamed';
               EXCEPTION
                    WHEN OTHERS THEN
                        mRespCode := SQLCODE;
                        mRespStr :=  SUBSTR(SQLERRM, 1, 200);
                        DBMS_OUTPUT.PUT_LINE(mObjectName || ' ' || SUBSTR(SQLERRM, 1, 200));
               END;
               mSql := mSql || ';';
        END IF;
        BEGIN
            EXECUTE IMMEDIATE mInsertSQl
            USING
                 mObjectName, mObjectType, mRenamedObjectName, mSql, mRollbackSql, mRespCode, mRespStr;
                COMMIT;
        END;
    END LOOP;
    close mDbaObjectCur;

    DBMS_OUTPUT.PUT_LINE('FInished');
END;
/
