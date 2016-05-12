declare
    TYPE assoc_array IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);
    obj_path_array assoc_array;
    obj_type_array assoc_array;
    --mObjType VARCHAR2(50) := 'FUNCTION';
    --mDirPath VARCHAR2(100) := 'DEVPDB_FUNC'; 
    TYPE ObjCurType  IS REF CURSOR;
    mObjTypeCursor ObjCurType;
    mObjName VARCHAR2(100);    
    mObjType VARCHAR2(50);
    mObjTypeLookup VARCHAR2(50);
    mDirPath VARCHAR2(100);
    mContent Clob;
    vFile utl_file.file_type;
    mFilePrefix VARCHAR2(10) := '.sql';
    clob_part VARCHAR2(1024);
    clob_length NUMBER;
    offset      NUMBER := 1;
    mExists     BOOLEAN;
    mFileLength NUMBER;
    mBlockSize NUMBER; 
begin
    obj_path_array('FUNCTION') := 'SCHEMA_FUNC_SRC';
    obj_path_array('SEQUENCE') := 'SCHEMA_SEQ_SRC';
    obj_path_array('PROCEDURE') := 'SCHEMA_PROC_SRC';
    obj_path_array('DB_LINK') := 'SCHEMA_DBLINK_SRC';
    obj_path_array('PACKAGE_BODY') := 'SCHEMA_PKG_SRC';
    obj_path_array('PACKAGE_SPEC') := 'SCHEMA_PKG_SRC';
    obj_path_array('TRIGGER') := 'SCHEMA_TRG_SRC';
    obj_path_array('VIEW') := 'SCHEMA_VIEW_SRC';
    obj_path_array('INDEX') := 'SCHEMA_INDEX_SRC';
    obj_path_array('TABLE') := 'SCHEMA_TABLE_SRC';
    obj_path_array('CONSTRAINT') := 'SCHEMA_CONSTR_SRC';
    obj_path_array('MATERIALIZED_VIEW') := 'SCHEMA_MV_SRC';
    obj_path_array('MATERIALIZED_VIEW_LOG') := 'SCHEMA_MV_SRC';
    
    obj_type_array('DB_LINK') := 'DATABASE LINK';
    obj_type_array('PACKAGE_BODY') := 'PACKAGE';
    obj_type_array('PACKAGE_SPEC') := 'PACKAGE';
    
    mObjType := obj_path_array.first;
    while (mObjType is not null)
    LOOP        
        BEGIN
            mDirPath := obj_path_array(mObjType);
            
            IF obj_type_array.EXISTS(mObjType)
            then
               mObjTypeLookup := obj_type_array(mObjType);
            ELSE
               mObjTypeLookup := mObjType;
            END IF;
            
            DBMS_OUTPUT.PUT_LINE(mObjType || '  ' || mObjTypeLookup || '  ' || mDirPath   );
            
            OPEN mObjTypeCursor FOR 'select object_name from dba_objects where
                                     owner = ''TAG'' and 
                                     object_type = :mObjTypeLookup' USING mObjTypeLookup;
            LOOP
                 BEGIN
                      FETCH mObjTypeCursor INTO mObjName;
                      EXIT WHEN mObjTypeCursor%NOTFOUND;
                      --DBMS_OUTPUT.PUT_LINE(mObjName);
                      BEGIN
                        select dbms_metadata.GET_DDL(mObjType,mObjName,'TAG') INTO mContent from dual;
                        IF mObjType = 'PACKAGE_BODY'
                        THEN
                             mFilePrefix := '.pkb';
                        ELSIF mObjType = 'PACKAGE_SPEC'
                        THEN
                             mFilePrefix := '.pks';
                        ELSE
                             mFilePrefix := '.sql';
                        END IF;
                        DBMS_OUTPUT.PUT_LINE('Processing ObjectType( ' || mObjType ||
                                             ') ObjectName( ' || mObjName || 
                                             ') Owner(TAG) File( ' || mObjName || mFilePrefix || ')');
                      EXCEPTION
                      WHEN OTHERS THEN
                            DBMS_OUTPUT.PUT_LINE('Object Name(' || mObjName || ') Object Type(' || mObjType || ')  SqlError(' || SQLERRM || ')');
                            mContent := SQLERRM;
                      END;
                      BEGIN
                          offset := 1;
                          clob_length := dbms_lob.getlength(mContent);
                          vFile := utl_file.fopen(mDirPath ,lower(mObjName || mFilePrefix),'w');

                          DBMS_OUTPUT.PUT_LINE('Writing to file(' || mObjName || mFilePrefix || ' ) Size (' || clob_length || ')');
                          while ( offset <  clob_length )
                          loop
                             utl_file.put(vFile,
                                          dbms_lob.substr(mContent,32760,offset) );
                             utl_file.fflush(vFile);
                             offset := offset + 32760;
                          end loop;
/*
                          LOOP
                          EXIT WHEN offset >= clob_length;
                            clob_part := DBMS_LOB.SUBSTR ( mContent, 1024, offset);
                            UTL_FILE.PUT_LINE(vFile, clob_part, FALSE);
                            offset := offset + 1024;
                          END LOOP;
*/                          
/*                          WHILE offset < clob_length
                          LOOP
                               clob_part := DBMS_LOB.SUBSTR ( mContent, 1024, offset);
                               EXIT WHEN clob_part IS NULL;
                               UTL_FILE.PUT_LINE(vFile, clob_part, FALSE);
                               offset := offset + LEAST(LENGTH(clob_part)+1,1024);
                          END LOOP;*/

                          UTL_FILE.FFLUSH(vFile);
                          utl_file.new_line(vFile);
                          utl_file.put(vFile,'/'); -- note use of file handle vFile
                          utl_file.fclose(vFile);
                          utl_file.fgetattr(mDirPath, lower(mObjName || mFilePrefix), mExists, mFileLength, mBlockSize);

                          DBMS_OUTPUT.PUT_LINE('Written to file(' || mObjName || mFilePrefix || ' ) Size (' || offset || ') Length ' || clob_length || ') ');

                          IF mFileLength < clob_length
                          THEN
                              Raise_Application_Error (-20343, 'File size does not match' || mDirPath || '/' || lower(mObjName || mFilePrefix));
                          END IF;
                      EXCEPTION
                          WHEN OTHERS THEN
                              DBMS_OUTPUT.PUT_LINE('=================================================================');
                              DBMS_OUTPUT.PUT_LINE('Object Type(' || mObjType || ') ObjectName(' || mObjName || ') ' ||
                                                   ' DIR(' || mDirPath || ') ' ||  
                                                   ' File(' || mObjName || mFilePrefix || ') SqlError(' || SQLERRM || ')');
                              DBMS_OUTPUT.PUT_LINE('=================================================================');
                       END;
                       DBMS_OUTPUT.PUT_LINE('Processed ObjectType( ' || mObjType ||
                                             ') ObjectName( ' || mObjName ||
                                             ') Owner(TAG) File( ' || mObjName || mFilePrefix || ')');
                 EXCEPTION
                      WHEN OTHERS THEN
                          DBMS_OUTPUT.PUT_LINE('Failed to fetch next object name for Object Type(' || mObjType || ')  SqlError(' || SQLERRM || ')');
                 END;
            END LOOP;   
            CLOSE mObjTypeCursor;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Object Type(' || mObjType || ') Sql Error(' || SQLERRM || ')');
        END;
        mObjType := obj_path_array.next(mObjType);
   END LOOP;
EXCEPTION
    WHEN OTHERS
    THEN
        DBMS_OUTPUT.PUT_LINE('Sql Error(' ||  SQLERRM || ')');
end;
/

