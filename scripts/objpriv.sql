set linesize 36
set pagesize 60
set verify off
-- 
ttitle on
ttitle center 'Roles granted to &1' skip 2

clear breaks

column grantee            format a30          heading 'Role'
column siud               format a4           heading 'siud'

SELECT tp.grantee,
       DECODE( tp.select_priv, 'Y', 'X', 'A', 'X', '-' ) ||
       DECODE( tp.insert_priv, 'Y', 'X', 'A', 'X', '-' ) ||
       DECODE( tp.update_priv, 'Y', 'X', 'A', 'X', '-' ) ||
       DECODE( tp.delete_priv, 'Y', 'X', 'A', 'X', '-' ) AS SIUD
from   table_privileges tp, dba_roles dr
where  tp.owner = USER
and    tp.table_name = UPPER( '&1' )
and    tp.grantee = dr.role
UNION ALL
SELECT tp.grantee,
       DECODE( tp.select_priv, 'Y', 'X', 'A', 'X', '-' ) ||
       DECODE( tp.insert_priv, 'Y', 'X', 'A', 'X', '-' ) ||
       DECODE( tp.update_priv, 'Y', 'X', 'A', 'X', '-' ) ||
       DECODE( tp.delete_priv, 'Y', 'X', 'A', 'X', '-' ) AS SIUD
from   table_privileges tp
where  tp.owner = USER
       and tp.table_name = UPPER( '&1' )
       and ( tp.grantee = 'PUBLIC' )
order by 1, 2;

ttitle center 'Users with access to &1' skip 2

SELECT tp.grantee,
       DECODE( tp.select_priv, 'Y', 'X', 'A', 'X', '-' ) ||
       DECODE( tp.insert_priv, 'Y', 'X', 'A', 'X', '-' ) ||
       DECODE( tp.update_priv, 'Y', 'X', 'A', 'X', '-' ) ||
       DECODE( tp.delete_priv, 'Y', 'X', 'A', 'X', '-' ) AS SIUD
from   table_privileges tp, dba_roles dr
where  tp.table_name = UPPER( '&1' )
and    tp.grantee = dr.role(+)
and    dr.role is null
and    tp.grantee <> 'PUBLIC';

ttitle off

set linesize 80
clear breaks

