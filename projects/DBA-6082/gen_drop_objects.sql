set echo on time on timing on
set heading on
set serveroutput on

DECLARE
    TYPE ref_type_cur IS REF CURSOR;
    mDbaObjectCur ref_type_cur;
    mObjectName VARCHAR2(100):= null;
    mObjectType VARCHAR2(100);
    mSql VARCHAR2(4000);
    mHistoryTable VARCHAR2(30) := 'DB_SCHEMA_OBJ_TO_DROP_0127';
BEGIN
    
    OPEN mDbaObjectCur FOR 'SELECT OBJECT_TYPE,RENAMED_OBJ_NAME FROM ' || mHistoryTable || ' order by object_type';
    LOOP
        FETCH mDbaObjectCur INTO mObjectType, mObjectName;
        EXIT WHEN mDbaObjectCur%NOTFOUND;
            mSql := '';
            IF mObjectType = 'TABLE'
            THEN
                mSql := 'DROP TABLE ' ||     mObjectName || '  CASCADE CONSTRAINTS; ';    
            ELSIF  mObjectType = 'VIEW'
            THEN
                mSql := 'DROP VIEW ' ||     mObjectName || ';';
            ELSIF  mObjectType = 'SEQUENCE'
            THEN
                mSql := 'DROP SEQUENCE ' ||     mObjectName || ';';
            END IF;
            DBMS_OUTPUT.PUT_LINE(mSql);
    END LOOP;
 EXCEPTION
    WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(mObjectName || ' ' || SUBSTR(SQLERRM, 1, 200));
END;
