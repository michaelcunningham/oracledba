set echo on time on timing on
set heading on
set serveroutput on
spool /mnt/dba/projects/DBA-6082/rename_objects_spdb08.log

DECLARE
    TYPE ref_type_cur IS REF CURSOR;
    mDbaObjectCur ref_type_cur;
    mTableName VARCHAR2(100):= null;
    mObjectName VARCHAR2(100):= null;
    mRenamedObjectName VARCHAR2(100):= null;
    mObjectType VARCHAR2(100);
    mStartPartion NUMBER(3) := 48;
    mEndPartition NUMBER(3) := 55;
    mSaveHistoryTable VARCHAR2(1) := 'Y';
    mSql VARCHAR2(4000);
    mRespStr VARCHAR2(55) := 'SUCCESS';
    mRespCode NUMBER(5) := 0;
BEGIN
    BEGIN
        SELECT object_name, object_type
        INTO mTableName, mObjectType
        FROM dba_objects
        WHERE object_name = 'DB_OBJECTS_TO_DROP' and 
              OBJECT_TYPE = 'TABLE' AND
              OWNER = 'TAG';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mTableName := NULL;
            DBMS_OUTPUT.PUT_LINE('DB_OBJECTS_TO_DROP does not exists');
    END;

    IF mTableName is NOT NULL AND
       upper(mSaveHistoryTable) = 'N'
    THEN
        --execute immediate 'DROP TABLE DB_OBJECTS_TO_DROP CASCADE CONSTRAINTS';
        DBMS_OUTPUT.PUT_LINE('DB_OBJECTS_TO_DROP table is dropped');
    END IF;

    IF mTableName is NULL OR
       (mTableName is NOT NULL AND
       upper(mSaveHistoryTable) = 'Y')
    THEN
        DBMS_OUTPUT.PUT_LINE('DB_OBJECTS_TO_DROP table is created');
        execute immediate 'create table DB_OBJECTS_TO_DROP (
                                OBJECT_NAME VARCHAR2(128) NOT NULL,
                                OBJECT_TYPE VARCHAR2(128) NOT NULL,
                                RENAMED_OBJ_NAME VARCHAR2(128),
                                SQL_STMT VARCHAR2(2000),
                                STATUS_CODE NUMBER(10),
                                STATUS VARCHAR2 (201),
                                DATE_ADDED DATE DEFAULT SYSDATE
                            )';
     END IF;
     /**** Building object query *****/
    mSql := 'SELECT object_name, OBJECT_TYPE
             FROM dba_objects
             WHERE owner = ''TAG'' AND
                   (object_type = ''TABLE'' OR
                    object_type = ''VIEW'' OR
                    object_type = ''SEQUENCE'') AND
           (
             ';
    FOR pkey in mStartPartion..mEndPartition
    LOOP
        mSql:= mSql || '(object_name like ''%_P'|| pkey || ''' AND
                         object_name not like ''D_%P' || pkey || ''')';
        IF pkey < mEndPartition
        THEN
            mSql := mSql || ' OR ';
        END IF;
    END LOOP;
    mSql := mSql || ' ) ';
    DBMS_OUTPUT.PUT_LINE(mSql);
    OPEN mDbaObjectCur FOR mSql;
    LOOP
        FETCH mDbaObjectCur INTO mObjectName,mObjectType;
        EXIT WHEN mDbaObjectCur%NOTFOUND;
        mSql:= '';
        mRespCode := 0;
        IF upper(mObjectType) = 'TABLE'
        THEN
           mRenamedObjectName := 'D_' || mObjectName;
           IF LENGTH( mRenamedObjectName ) > 30
           THEN
              DBMS_OUTPUT.PUT_LINE('Table name is to big. Table: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
              mRenamedObjectName := 'D_' || SUBSTR(mObjectName,3);
              DBMS_OUTPUT.PUT_LINE('Table name truncated. Table: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
           END IF;
              mSql := 'ALTER TABLE ' || mObjectName || ' RENAME TO ' || mRenamedObjectName ;
              DBMS_OUTPUT.PUT_LINE(mSql);
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
        ELSIF upper(mObjectType) = 'SEQUENCE' OR
              upper(mObjectType) = 'VIEW'
        THEN
            mRenamedObjectName := 'D_' || mObjectName;
            IF LENGTH(mRenamedObjectName ) > 30
           THEN
              DBMS_OUTPUT.PUT_LINE(mObjectType || ' name is to big. Old: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
              mRenamedObjectName := 'D_' || SUBSTR(mObjectName,3);
              DBMS_OUTPUT.PUT_LINE(mObjectType || ' has been truncated. Old: '  ||  mObjectName || ' Renamed: ' || mRenamedObjectName);
           END IF;
              mSql := 'RENAME ' || mObjectName || ' TO ' || mRenamedObjectName ;
              DBMS_OUTPUT.PUT_LINE(mSql);
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
        END IF;
        BEGIN
            EXECUTE IMMEDIATE 'INSERT INTO DB_OBJECTS_TO_DROP(OBJECT_NAME, OBJECT_TYPE, RENAMED_OBJ_NAME, SQL_STMT, STATUS_CODE, STATUS)
                VALUES (:mObjectName, :mObjectType, :mRenamedObjectName, :mSql, :mRespCode, :mRespStr)'
            USING
                 mObjectName, mObjectType, mRenamedObjectName, mSql, mRespCode, mRespStr   ;
                COMMIT;
        END;
    END LOOP;
    close mDbaObjectCur;
    DBMS_OUTPUT.PUT_LINE('FInished');
END;
/
