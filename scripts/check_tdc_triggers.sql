select OWNER , STATUS , count (*) from dba_triggers where OWNER in ('NOVAPRD','SECURITY','VISTAPRD') group by OWNER , STATUS order by OWNER , STATUS 
/
