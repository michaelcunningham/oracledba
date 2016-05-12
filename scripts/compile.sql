--  #########################################################################
--
--  PROGRAM NAME
--    compile.sql
--
--  DESCRIPTION
--    Compile invalid PL/SQL objects for connected user.
--
--  MODIFIED  (MM/DD/YY)
--    Michael Cunningham  12/16/96 - Creation
--    Michael Cunningham  12/27/96 - Modified so it compiles all objects for
--                                   the connected user.
--    Michael Cunningham  01/27/97 - Modify script so it will delete spool
--                                   file (#_C#.SQL) after it is executed.
--
--  #########################################################################
set heading off
set feedback off
set term off

spool compile1.sql
PROMPT PROMPT Beginning to compile PLSQL objects..
PROMPT

SELECT 'ALTER ' || object_type || ' ' || object_name || ' COMPILE;'
FROM   user_objects
WHERE  status != 'VALID'
AND    object_type IN( 'FUNCTION', 'PROCEDURE' )
ORDER BY object_type;

SELECT 'ALTER PACKAGE ' || object_name || ' COMPILE;'
FROM   user_objects
WHERE  status != 'VALID'
AND    object_type IN( 'PACKAGE' );

SELECT 'ALTER ' || object_type || ' ' || object_name || ' COMPILE;'
FROM   user_objects
WHERE  status != 'VALID'
AND    object_type IN( 'TRIGGER' )
ORDER BY object_type;

SELECT 'ALTER ' || object_type || ' ' || object_name || ' COMPILE;'
FROM   user_objects
WHERE  status != 'VALID'
AND    object_type IN( 'VIEW' )
ORDER BY object_type;

PROMPT
PROMPT PROMPT Finished compiling PLSQL objects for..

spool off
set heading on
set feedback on
set term on

@@compile1.sql

set heading off
set feedback off
set term off

spool compile2.sql
PROMPT PROMPT Beginning to compile invalid PLSQL Package Body objects..
PROMPT

SELECT 'ALTER PACKAGE ' || object_name || ' COMPILE BODY;'
FROM   user_objects
WHERE  status != 'VALID'
AND    object_type IN( 'PACKAGE BODY' );

PROMPT
PROMPT PROMPT Finished compiling invalid PLSQL Package Body objects..

spool off
set heading on
set feedback on
set term on

@@compile2.sql

-- $del compile_.sql
-- host rm -f compile_.sql

-- Now run the script that shows the name of pl/sql objects
-- which have compile errors.
@@se
