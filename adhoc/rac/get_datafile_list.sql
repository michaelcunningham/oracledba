set pagesize 0
set heading off
set verify off
set echo off
select name from v$datafile where ts# = ( select ts# from v$tablespace where name = '&tablespace_name' );
