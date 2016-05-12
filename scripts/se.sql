set linesize 55
-- 
ttitle on
ttitle center 'PL/SQL Objects with compile errors' skip 2

column object_name        format a30          heading 'Object Name'
column object_typ         format a30          heading 'Object Type'
column created            format a20          heading 'Created'

SELECT DISTINCT name, type
FROM   user_errors
WHERE  type <> 'JAVA CLASS'
ORDER BY name;


set linesize 80
ttitle center 'Objects with invalid status' skip 2

SELECT object_name, object_type, TO_CHAR( created, 'DD-MON-YYYY HH24:MI' ) created
FROM   user_objects
WHERE  status <> 'VALID'
AND    object_type NOT IN( 'JAVA CLASS', 'UNDEFINED' );

ttitle off

set linesize 80
