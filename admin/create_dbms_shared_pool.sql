@/oracle/app/oracle/product/10.2.0/db_1/rdbms/admin/dbmspool.sql
GRANT EXECUTE ON dbms_shared_pool TO novaprd;
create public synonym dbms_shared_pool for sys.dbms_shared_pool;
