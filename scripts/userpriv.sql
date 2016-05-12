set linesize 66
set pagesize 60
set verify off
-- 
ttitle on
ttitle center 'Private table privileges for &1 (LIKE)' skip 2

clear breaks

column grantee            format a30          heading 'User'
column granted_role       format a30          heading 'Granted Role'
column table_name         format a30          heading 'Table Name'
column siud               format a4           heading 'siud'

SELECT	tp.grantee, tp.table_name,
	DECODE( tp.select_priv, 'Y', 'X', 'A', 'X', 'S', 'S', '-' ) ||
	DECODE( tp.insert_priv, 'Y', 'X', 'A', 'X', 'S', 'S', '-' ) ||
	DECODE( tp.update_priv, 'Y', 'X', 'A', 'X', 'S', 'S', '-' ) ||
	DECODE( tp.delete_priv, 'Y', 'X', 'A', 'X', 'S', 'S', '-' ) AS SIUD
FROM	table_privileges tp
WHERE	tp.owner = USER
AND	tp.grantee LIKE UPPER( '&1%' )
UNION
SELECT	NULL grantee, NULL table_name, NULL SIUD
FROM	dual
ORDER BY 1, 2;

ttitle center 'Role privilges for &1 (LIKE)' skip 2

SELECT	grantee, granted_role
FROM	dba_role_privs
WHERE	grantee LIKE UPPER( '&1%' )
ORDER BY DECODE( granted_role, 'CONNECT', 9, 'RESOURCE', 8, 'DBA', 7, 1 ), grantee;

ttitle off

set linesize 80
clear breaks

