CREATE OR REPLACE FUNCTION TAG.SQUIRREL_GET_ERROR_OFFSET (query IN VARCHAR2)
   RETURN NUMBER
   AUTHID CURRENT_USER
IS
   l_theCursor   INTEGER DEFAULT DBMS_SQL.open_cursor;
   l_status      INTEGER;
BEGIN
   BEGIN
      DBMS_SQL.parse (l_theCursor, query, DBMS_SQL.native);
   EXCEPTION
      WHEN OTHERS
      THEN
         l_status := DBMS_SQL.last_error_position;
   END;

   DBMS_SQL.close_cursor (l_theCursor);
   RETURN l_status;
END;
/