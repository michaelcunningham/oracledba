select substr(comp_id,1,15) comp_id,substr(comp_name,1,30)
comp_name,substr(version,1,10) version,status
from dba_registry order by modified
/
