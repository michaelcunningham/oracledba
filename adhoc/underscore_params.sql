REM File: underscoreparms.sql
REM Desc: see underscore '_' AKA hidden DB parameters 
set echo off lines 149 pages 9999 feed off
clear col
clear break
clear compute
ttitle off
btitle off
COLUMN Param FORMAT a42 wrap head 'Underscore Parameter'
COLUMN Descr FORMAT a75 wrap head 'Description'
COLUMN SessionVal FORMAT a12 head 'Value|Session'
COLUMN InstanceVal FORMAT a12 head 'Value|Instnc'
ttitle skip 1 center 'All Underscore Parameters' skip 2

spool underscoreparms.lis

SELECT 
a.ksppinm Param , 
b.ksppstvl SessionVal ,
c.ksppstvl InstanceVal,
a.ksppdesc Descr 
FROM 
x$ksppi a , 
x$ksppcv b , 
x$ksppsv c
WHERE 
a.indx = b.indx AND 
a.indx = c.indx AND 
a.ksppinm LIKE '/_%' escape '/'
AND a.ksppinm LIKE '%flashback%'
ORDER BY
1
/
