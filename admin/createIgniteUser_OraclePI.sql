REM connect as SYS on Mon DB
REM create Ignite user for Ignite for Oracle.
REM Modify the directory path in the last step if required

prompt Enter Ignite Username:
accept Ignite_Username
prompt Enter Ignite Password:
accept Ignite_Password
prompt Enter Ignite Tablespace:
accept TS
prompt Enter Ignite Temporary Tablespace:
accept TTS

#drop user &Ignite_Username cascade;

create user &Ignite_Username identified by &Ignite_Password
default tablespace &TS temporary tablespace &TTS;

grant create table to &Ignite_Username;
grant create synonym to &Ignite_Username;
grant create session to &Ignite_Username;
grant create sequence to &Ignite_Username;
grant unlimited tablespace to &Ignite_Username;

grant select on dba_views to &Ignite_Username;
grant select on dba_objects to &Ignite_Username;
grant select on user_synonyms to &Ignite_Username;
grant select any dictionary to &Ignite_Username;

REM create views

create or replace view x_$KSUSE     as select * from x$ksuse;
create or replace view x_$ksusecst  as select * from x$ksusecst;
create or replace view X_$KCCCF     as select * from x$KCCCF;
create or replace view X_$KGLNA1    AS select * from x$kglna1;
create or replace view X_$KGLNA     AS select * from x$KGLNA;
create or replace view x_$KGLCURSOR AS select * from x$KGLCURSOR;

grant select on x_$ksuse to &Ignite_Username;
grant select on x_$ksusecst to &Ignite_Username;
grant select on x_$kcccf to &Ignite_Username;
grant select on x_$kglna1 to &Ignite_Username;
grant select on x_$kglna to &Ignite_Username;
grant select on x_$kglcursor to &Ignite_Username;

grant select on v_$parameter to &Ignite_Username;
grant select on v_$instance to &Ignite_Username;
grant select on v_$sql_plan to &Ignite_Username;

create or replace synonym &Ignite_Username..x$ksuse for sys.x_$ksuse;
create or replace synonym &Ignite_Username..x$ksusecst for sys.x_$ksusecst;
create or replace synonym &Ignite_Username..x$kcccf for sys.x_$kcccf;
create or replace synonym &Ignite_Username..x$kglna for sys.x_$kglna;
create or replace synonym &Ignite_Username..x$kglna1 for sys.x_$kglna1;
create or replace synonym &Ignite_Username..x$kglcursor for sys.x_$kglcursor;
create or replace synonym &Ignite_Username..mproc for dual;

-- Create utl_con package used for getting explain plan and block data
@/dba/admin/utl_con_8iplus.plb

grant execute on sys.utl_con to &Ignite_Username;
