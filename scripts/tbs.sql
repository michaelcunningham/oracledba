set feedback off
set term off
set heading off
ttitle off
set pagesize 200
set linesize 102
column sys_date format A15 noprint new_value rd
select to_char(sysdate,'DD-Mon-YY HH24:MI') sys_date
from dual;
column db noprint new_value _db
select name db from v$database;
set heading on
set feedback on
ttitle on
set term on
ttitle -
    skip center -
    "$ORACLE_SID=&_db  DBA002:Tablespace Status Report" -
    skip2 -
    center rd -
    skip2
 
column tablespace_name   format a18              heading 'Tablespace'
column total             format 99,999,999,999   heading 'Total Kb'
column avail             format 99,999,999,999   heading 'Free Kb'
column frags             format 9999             heading 'Pieces'
column big               format 99,999,999,999   heading 'Max Kb' noprint
column small             format 99,999,999,999   heading 'Min Kb' noprint
column using             format 99,999,999,999   heading 'Using Kb'
column avg               format 9,999,999,999    heading 'Avg Kb' noprint
column pct_free          format 990              heading '% Free'
column max_autoextend    format 9,999,999,999    heading 'Max AutoExt'
column autoextend_used   format 990              heading '% AutoUsed'
 
break on report
compute sum of total            on report
compute sum of avail            on report
compute sum of using            on report
compute sum of max_autoextend   on report

select * from
        (
        select a.tablespace_name,
                a.sum_bytes/1024 total,
                nvl(sum(b.bytes)/1024,0) avail,
                --count(b.bytes) frags,
                nvl(max(b.bytes)/1024,0) big,
                nvl(min(b.bytes)/1024,0) small,
                ((a.sum_bytes/1024)-(nvl(sum(b.bytes)/1024,0))) using,
                nvl(avg(b.bytes)/1024,0) avg,
                round(round(nvl(sum(b.bytes)/1024,0))/(nvl(a.sum_bytes/1024,0))*100,0) pct_free,
                sum(a.sum_maxbytes)/1024 max_autoextend,
                round(round(((((a.sum_bytes/1024)-(nvl(sum(b.bytes)/1024,0))))/(a.sum_maxbytes/1024))*100),0) autoextend_used
        from    (
                select  tablespace_name, sum( bytes ) sum_bytes,
                        decode( autoextensible, 'YES', sum( maxbytes ), null ) sum_maxbytes
                from    sys.dba_data_files
                group by tablespace_name, autoextensible
                ) a,
                (
                select  tablespace_name, sum( bytes ) bytes
                from    sys.dba_free_space
                group by tablespace_name
                ) b
        where
                a.tablespace_name = b.tablespace_name(+)
        group by
                a.tablespace_name,
                a.sum_bytes,
                a.sum_maxbytes
        order by
                a.tablespace_name
        )
union all
select  tsh.tablespace_name,
        sum( dtf.bytes )/1024 total,
        sum( tsh.bytes_free )/1024 avail,
        --null frags,
        null big,
        null small,
        ((sum(dtf.bytes)/1024)-(sum(tsh.bytes_free)/1024)) using,
        null avg,
round(( sum(tsh.bytes_free)/sum(dtf.bytes)) *100,0) pct_free,
        decode( autoextensible, 'YES', sum(dtf.maxbytes)/1024, null ) max_autoextend,
        null autoextend_avail
--      round(round((1-(((sum(dtf.bytes)/1024)-(sum(tsh.bytes_free)/1024)))
--              / (decode( autoextensible, 'YES', sum( dtf.maxbytes ), sum( dtf.bytes ) )/1024))*100),0) autoextend_avail
from    dba_temp_files dtf, v$temp_space_header tsh
where   dtf.tablespace_name = tsh.tablespace_name
and     dtf.file_id = tsh.file_id
group by tsh.tablespace_name, autoextensible;
