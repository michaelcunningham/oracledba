set linesize 90
set pagesize 60
-- 
ttitle on
ttitle center 'SQL Statement matching sql address' skip 2

clear breaks

column command_type       format 999          heading 'Command Type'
column piece              format 9999         heading 'Sql Piece'
column sql_text           format a64          heading 'SQL Text (piece - 64 bytes)'

select command_type, piece,
       sql_text
from   v$sqltext
where  sql_id = '&1'
order by piece;

ttitle off

set linesize 120
clear breaks

