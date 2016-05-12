select	*
from	dba_sys_privs
where	grantee = 'NOVAPRD'
and	privilege = 'UNLIMITED TABLESPACE';

