Rem
Rem $Header: rdbms/admin/spcusr.sql /main/34 2009/02/25 13:20:29 shsong Exp $
Rem
Rem spcusr.sql
Rem
Rem Copyright (c) 1999, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      spcusr.sql
Rem
Rem    DESCRIPTION
Rem      SQL*Plus command file to create user which will contain the
Rem      STATSPACK database objects.
Rem
Rem    NOTES
Rem      Must be run from connected to SYS (or internal)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      01/30/09 - update STATS$V_$FILESTATXS etc  
Rem    shsong      07/11/08 - add stats$x$kccfe etc
Rem    cdgreen     03/14/07 - 11 F2
Rem    cdgreen     06/01/06 - 11 F1 
Rem    cdgreen     05/10/06 - 5215982
Rem    cdgreen     08/22/05 - 4562627
Rem    cdgreen     05/24/05 - 4246955
Rem    cdgreen     04/18/05 - 4228432
Rem    cdgreen     10/29/04 - 10gR2_sqlstats
Rem    cdgreen     08/12/04 - 10g R2
Rem    vbarrier    02/12/04 - 3412853
Rem    cdialeri    12/04/03 - 3290482
Rem    cdialeri    10/14/03 - 10g - streams - rvenkate 
Rem    cdialeri    08/05/03 - 10g F3 
Rem    vbarrier    02/25/03 - 10g RAC
Rem    cdialeri    11/15/02 - 10g F1
Rem    vbarrier    09/06/02 - SYSAUX and db default temp tbs
Rem    vbarrier    04/01/02 - 2290728
Rem    vbarrier    03/05/02 - Segment Statistics
Rem    cdialeri    02/07/02 - 2218573
Rem    cdialeri    11/30/01 - 9.2 - features 1
Rem    cdialeri    04/26/01 - 9.0
Rem    cdialeri    09/12/00 - sp_1404195
Rem    cdialeri    04/07/00 - 1261813
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    01/26/00 - 1169401
Rem    cdialeri    11/01/99 - 1059172
Rem    cdialeri    08/13/99 - Created
Rem

set echo off verify off showmode off feedback off;
whenever sqlerror exit sql.sqlcode

prompt
prompt Choose the PERFSTAT user's password
prompt ------------------------------------  

prompt Not specifying a password will result in the installation FAILING
prompt
--prompt &&perfstat_password

-- TDC defaults
column perfpwd noprint new_value perfstat_password
select 'perfstat' perfpwd from dual;

Rem Begin spooling after password has been entered
spool spcusr.lis

begin
  if '&&perfstat_password' is null then
    raise_application_error(-20101, 'Install failed - No password specified for PERFSTAT user');
  end if;
end;
/


Rem
Rem  Set up PERFSTAT's temporary and default tablespaces
Rem

prompt
prompt
prompt Choose the Default tablespace for the PERFSTAT user
prompt ----------------------------------------------------

prompt Below is the list of online tablespaces in this database which can
prompt store user data.  Specifying the SYSTEM tablespace for the user's 
prompt default tablespace will result in the installation FAILING, as 
prompt using SYSTEM for performance data is not supported.
prompt
prompt Choose the PERFSTAT users's default tablespace.  This is the tablespace
prompt in which the STATSPACK tables and indexes will be created.

column db_default format a28 heading 'STATSPACK DEFAULT TABLESPACE'

select tablespace_name, contents
     , decode(tablespace_name,'SYSAUX','*') db_default
  from sys.dba_tablespaces 
 where tablespace_name <> 'SYSTEM'
   and contents = 'PERMANENT'
   and status = 'ONLINE'
 order by tablespace_name;

prompt
prompt Pressing <return> will result in STATSPACK's recommended default
prompt tablespace (identified by *) being used.
prompt

set heading off
col default_tablespace new_value default_tablespace noprint

-- TDC defaults
select 'STATS' default_tablespace from dual;

select 'Using tablespace '||
       upper(nvl('&&default_tablespace','SYSAUX'))||
       ' as PERFSTAT default tablespace.'
     , nvl('&default_tablespace','SYSAUX') default_tablespace
  from sys.dual;
set heading on

begin
  if upper('&&default_tablespace') = 'SYSTEM' then
    raise_application_error(-20101, 'Install failed - SYSTEM tablespace specified for DEFAULT tablespace');
  end if;
end;
/


prompt
prompt
prompt Choose the Temporary tablespace for the PERFSTAT user
prompt ------------------------------------------------------

prompt Below is the list of online tablespaces in this database which can
prompt store temporary data (e.g. for sort workareas).  Specifying the SYSTEM 
prompt tablespace for the user's temporary tablespace will result in the 
prompt installation FAILING, as using SYSTEM for workareas is not supported.

prompt
prompt Choose the PERFSTAT user's Temporary tablespace.

column db_default format a26 heading 'DB DEFAULT TEMP TABLESPACE'

-- TDC defaults
col temporary_tablespace new_value temporary_tablespace noprint
select 'TEMP' temporary_tablespace  from dual;

select t.tablespace_name, t.contents
     , decode(dp.property_name,'DEFAULT_TEMP_TABLESPACE','*') db_default
  from sys.dba_tablespaces t
     , sys.database_properties dp
 where t.contents           = 'TEMPORARY'
   and t.status             = 'ONLINE'
   and dp.property_name(+)  = 'DEFAULT_TEMP_TABLESPACE'
   and dp.property_value(+) = t.tablespace_name
 order by tablespace_name;

prompt
prompt Pressing <return> will result in the database's default Temporary 
prompt tablespace (identified by *) being used.
prompt

set heading off
col temporary_tablespace new_value temporary_tablespace noprint
select 'Using tablespace '||
       nvl('&&temporary_tablespace',property_value)||
       ' as PERFSTAT temporary tablespace.'
     , nvl('&&temporary_tablespace',property_value) temporary_tablespace
  from database_properties
 where property_name='DEFAULT_TEMP_TABLESPACE';
set heading on

begin
  if upper('&&temporary_tablespace') = 'SYSTEM' then
    raise_application_error(-20101, 'Install failed - SYSTEM tablespace specified for TEMPORARY tablespace');
  end if;
end;
/


prompt
prompt
prompt ... Creating PERFSTAT user

create user perfstat 
  identified by &&perfstat_password
  default tablespace &&default_tablespace
  temporary tablespace &&temporary_tablespace;

alter user PERFSTAT quota unlimited on &&default_tablespace;

prompt
prompt
prompt ... Installing required packages

Rem
Rem  Install required packages
Rem

@@dbmspool


prompt
prompt
prompt ... Creating views

Rem
Rem  Create X$views as a temporary workaround to externalizing these objects
Rem  through V$views

create or replace view STATS$X_$KCBFWAIT as select * from X$KCBFWAIT;
create or replace public synonym  STATS$X$KCBFWAIT for STATS$X_$KCBFWAIT;
create or replace view STATS$X_$KSPPSV as select * from X$KSPPSV;
create or replace public synonym  STATS$X$KSPPSV for STATS$X_$KSPPSV;
create or replace view STATS$X_$KSPPI as select * from X$KSPPI;
create or replace public synonym STATS$X$KSPPI for STATS$X_$KSPPI;
create or replace view STATS$X_$KSXPPING as select * from X$KSXPPING;
create or replace public synonym STATS$X$KSXPPING for STATS$X_$KSXPPING;
create or replace view STATS$V_$FILESTATXS as
select ts.tsnam                    tsname
     , fn.fnnam	                   filename
     , fio.kcfiopyr                phyrds
     , fio.kcfiopyw                phywrts
     , round(fio.kcfioprt/10000)   readtim
     , round(fio.kcfiopwt/10000)   writetim
     , fio.kcfiosbr                singleblkrds
     , fio.kcfiopbr                phyblkrd
     , fio.kcfiopbw                phyblkwrt
     , round(fio.kcfiosbt/10000)   singleblkrdtim
     , fw.count                    wait_count
     , fw.time                     time
     , fn.fnfno                    file#
  from x$kcbfwait   fw
     , x$kcfio      fio
     , x$kccfe      fe
     , x$kccts      ts
     , x$kccfn      fn
 where ts.tstsn      = fe.fetsn
   and fio.kcfiofno  = fn.fnfno
   and fw.indx+1     = fn.fnfno
   and fe.fenum      = fn.fnfno
   and fe.fefnh      = fn.fnnum
   and fe.fedup      <> 0
   and fn.fntyp      = 4
   and fn.fnnam is not null
   and bitand(fn.fnflg, 4) != 4;
create or replace public synonym  STATS$V$FILESTATXS for STATS$V_$FILESTATXS;

create or replace view STATS$V_$TEMPSTATXS as
select ts.tsnam                      tsname
     , fn.fnnam                      filename
     , ftio.kcftiopyr                phyrds
     , ftio.kcftiopyw                phywrts
     , round(ftio.kcftioprt/10000)   readtim
     , round(ftio.kcftiopwt/10000)   writetim
     , ftio.kcftiosbr                singleblkrds
     , ftio.kcftiopbr                phyblkrd
     , ftio.kcftiopbw                phyblkwrt
     , round(ftio.kcftiosbt/10000)   singleblkrdtim
     , fw.count                      wait_count
     , fw.time                       time
     , fn.fnfno                      file#
  from x$kcbfwait   fw
     , x$kcftio     ftio
     , x$kccts      ts
     , x$kcctf      tf  
     , x$kccfn      fn
 where ts.tstsn       = tf.tftsn
   and ftio.kcftiofno = fn.fnfno
   and tf.tfnum       = fn.fnfno
   and tf.tffnh       = fn.fnnum
   and tf.tfdup       <> 0
   and fn.fntyp       = 7
   and fn.fnnam is not null 
   and bitand(tf.tfsta, 32) <> 32
   and fw.indx+1  = (fn.fnfno + (select value from v$parameter where name='db_files'));
create or replace public synonym  STATS$V$TEMPSTATXS for STATS$V_$TEMPSTATXS;

create or replace view STATS$V_$SQLXS as
select max(sql_text)        sql_text
     , max(sql_id)          sql_id
     , sum(sharable_mem)    sharable_mem
     , sum(sorts)           sorts
     , min(module)          module
     , sum(loaded_versions) loaded_versions
     , sum(fetches)         fetches
     , sum(executions)      executions
     , sum(px_servers_executions) px_servers_executions
     , sum(end_of_fetch_count) end_of_fetch_count
     , sum(loads)           loads
     , sum(invalidations)   invalidations
     , sum(parse_calls)     parse_calls
     , sum(disk_reads)      disk_reads
     , sum(direct_writes)   direct_writes
     , sum(buffer_gets)     buffer_gets
     , sum(application_wait_time)  application_wait_time
     , sum(concurrency_wait_time)  concurrency_wait_time
     , sum(cluster_wait_time)      cluster_wait_time
     , sum(user_io_wait_time)      user_io_wait_time
     , sum(plsql_exec_time)        plsql_exec_time
     , sum(java_exec_time)         java_exec_time
     , sum(rows_processed)  rows_processed
     , max(command_type)    command_type
     , address              address
     , old_hash_value       old_hash_value
     , max(hash_value)      hash_value
     , count(1)             version_count
     , sum(cpu_time)        cpu_time
     , sum(elapsed_time)    elapsed_time
     , null                 avg_hard_parse_time
     , max(outline_sid)     outline_sid
     , max(outline_category) outline_category
     , max(is_obsolete)     is_obsolete
     , max(child_latch)     child_latch
     , max(sql_profile)     sql_profile
     , max(program_id)      program_id
     , max(program_line#)   program_line#
     , max(exact_matching_signature) exact_matching_signature
     , max(force_matching_signature) force_matching_signature
     , max(last_active_time)         last_active_time
  from v$sql
 group by old_hash_value, address;
create or replace public synonym STATS$V$SQLXS for STATS$V_$SQLXS;


create or replace view STATS$V_$SQLSTATS_SUMMARY as
select sql_id
     , sum(parse_calls)           parse_calls
     , sum(disk_reads)            disk_reads
     , sum(buffer_gets)           buffer_gets
     , sum(executions)            executions
     , sum(version_count)         version_count
     , sum(cpu_time)              cpu_time
     , sum(elapsed_time)          elapsed_time
     , sum(sharable_mem)          sharable_mem
  from v$sqlstats
 group by sql_id;
create or replace public synonym STATS$V$SQLSTATS_SUMMARY for STATS$V_$SQLSTATS_SUMMARY;

prompt
prompt
prompt ... Granting privileges

Rem
Rem  Grant privileges
Rem

/*  System privileges  */
grant create session              to PERFSTAT;
grant alter  session              to PERFSTAT;
grant create table                to PERFSTAT;
grant create view                 to PERFSTAT;
grant create procedure            to PERFSTAT;
grant create sequence             to PERFSTAT;
grant create public synonym       to PERFSTAT;
grant drop   public synonym       to PERFSTAT;

/*  Select privileges on STATSPACK created views  */
grant select on STATS$X_$KCBFWAIT       to PERFSTAT;
grant select on STATS$X_$KSPPSV         to PERFSTAT;
grant select on STATS$X_$KSPPI          to PERFSTAT;
grant select on STATS$X_$KSXPPING       to PERFSTAT;
grant select on STATS$V_$FILESTATXS     to PERFSTAT;
grant select on STATS$V_$TEMPSTATXS     to PERFSTAT;
grant select on STATS$V_$SQLXS          to PERFSTAT;
grant select on STATS$V_$SQLSTATS_SUMMARY to PERFSTAT;

/*  Roles  */
grant SELECT_CATALOG_ROLE         to PERFSTAT;

/*  Select privs for catalog objects - ROLES disabled in PL/SQL packages  */
grant select on V_$PARAMETER      to PERFSTAT;
grant select on V_$SYSTEM_PARAMETER to PERFSTAT;
grant select on V_$DATABASE       to PERFSTAT;
grant select on V_$INSTANCE       to PERFSTAT;
grant select on GV_$INSTANCE      to PERFSTAT;
grant select on V_$LIBRARYCACHE   to PERFSTAT;
grant select on V_$LATCH          to PERFSTAT;
grant select on V_$LATCH_MISSES   to PERFSTAT;
grant select on V_$LATCH_CHILDREN to PERFSTAT;
grant select on V_$LATCH_PARENT   to PERFSTAT;
grant select on V_$ROLLSTAT       to PERFSTAT;
grant select on V_$ROWCACHE       to PERFSTAT;
grant select on V_$SGA            to PERFSTAT;
grant select on V_$BUFFER_POOL    to PERFSTAT;
grant select on V_$SGASTAT        to PERFSTAT;
grant select on V_$SYSTEM_EVENT   to PERFSTAT;
grant select on V_$SESSION        to PERFSTAT;
grant select on V_$SESSION_EVENT  to PERFSTAT;
grant select on V_$SYSSTAT        to PERFSTAT;
grant select on V_$WAITSTAT       to PERFSTAT;
grant select on V_$ENQUEUE_STATISTICS to PERFSTAT;
grant select on V_$SQLAREA        to PERFSTAT;
grant select on V_$SQL            to PERFSTAT;
grant select on V_$SQLTEXT        to PERFSTAT;
grant select on V_$SESSTAT        to PERFSTAT;
grant select on V_$BUFFER_POOL_STATISTICS to PERFSTAT;
grant select on V_$RESOURCE_LIMIT to PERFSTAT;
grant select on V_$DLM_MISC       to PERFSTAT;
grant select on V_$UNDOSTAT       to PERFSTAT;
grant select on V_$SQL_PLAN       to PERFSTAT;
grant select on V_$DB_CACHE_ADVICE to PERFSTAT;
grant select on V_$PGASTAT        to PERFSTAT;
grant select on V_$INSTANCE_RECOVERY to PERFSTAT;
grant select on V_$SHARED_POOL_ADVICE     to PERFSTAT;
grant select on V_$SQL_WORKAREA_HISTOGRAM to PERFSTAT;
grant select on V_$PGA_TARGET_ADVICE      to PERFSTAT;
grant select on V_$SEGSTAT                  to PERFSTAT;
grant select on V_$SEGMENT_STATISTICS       to PERFSTAT;
grant select on V_$SEGSTAT_NAME             to PERFSTAT;
grant select on V_$JAVA_POOL_ADVICE         to PERFSTAT;
grant select on V_$THREAD                   to PERFSTAT;
grant select on V_$CR_BLOCK_SERVER          to PERFSTAT;
grant select on V_$CURRENT_BLOCK_SERVER     to PERFSTAT;
grant select on V_$INSTANCE_CACHE_TRANSFER  to PERFSTAT;
grant select on V_$FILE_HISTOGRAM           to PERFSTAT;
grant select on V_$EVENT_HISTOGRAM          to PERFSTAT;
grant select on V_$EVENT_NAME               to PERFSTAT;
grant select on V_$SYS_TIME_MODEL           to PERFSTAT;
grant select on V_$SESS_TIME_MODEL          to PERFSTAT;
grant select on V_$STREAMS_CAPTURE           to PERFSTAT;
grant select on V_$STREAMS_APPLY_COORDINATOR to PERFSTAT;
grant select on V_$STREAMS_APPLY_READER      to PERFSTAT;
grant select on V_$STREAMS_APPLY_SERVER      to PERFSTAT;
grant select on V_$PROPAGATION_SENDER        to PERFSTAT;
grant select on V_$PROPAGATION_RECEIVER      to PERFSTAT;
grant select on V_$BUFFERED_QUEUES           to PERFSTAT;
grant select on V_$BUFFERED_SUBSCRIBERS      to PERFSTAT;
grant select on V_$RULE_SET                  to PERFSTAT;
grant select on V_$OSSTAT                    to PERFSTAT;
grant select on V_$PROCESS                   to PERFSTAT;
grant select on V_$PROCESS_MEMORY            to PERFSTAT;
grant select on V_$STREAMS_POOL_ADVICE       to PERFSTAT;
grant select on V_$SGA_TARGET_ADVICE         to PERFSTAT;
grant select on V_$SQLSTATS                  to PERFSTAT;
grant select on V_$MUTEX_SLEEP               to PERFSTAT;
grant select on V_$DYNAMIC_REMASTER_STATS    to PERFSTAT;
grant select on V_$IOSTAT_FUNCTION           to PERFSTAT;
grant select on V_$IOSTAT_FILE               to PERFSTAT;
grant select on V_$MEMORY_TARGET_ADVICE      to PERFSTAT;
grant select on V_$MEMORY_RESIZE_OPS         to PERFSTAT;
grant select on V_$MEMORY_DYNAMIC_COMPONENTS to PERFSTAT;
grant select on V_$MEMORY_CURRENT_RESIZE_OPS to PERFSTAT;


/*  Packages  */
grant execute on DBMS_SHARED_POOL to PERFSTAT;
grant execute on DBMS_JOB         to PERFSTAT;



prompt
prompt NOTE:
prompt   SPCUSR complete. Please check spcusr.lis for any errors.
prompt

spool off;
whenever sqlerror continue;
set echo on feedback on;
