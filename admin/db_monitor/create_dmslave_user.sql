--
-- Connect to the database as SYS and run this script.
--
create user dmslave identified by dmslave default tablespace sysaux quota 100m on sysaux;
grant connect to dmslave;
grant create sequence to dmslave;
grant create table to dmslave;
grant create public synonym to dmslave;
grant drop public synonym to dmslave;
grant create trigger to dmslave;
grant administer database trigger to dmslave;
grant select on v_$session to dmslave;
