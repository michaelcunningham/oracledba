column name format a30
column value format a10
column sessions_current format 999,999
column sessions_highwater format 999,999
select name, value from v$parameter where name = 'processes';
select sessions_current, sessions_highwater from v$license;

