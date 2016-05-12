set termout off
whenever sqlerror exit 1
select count(*) from dual;
--select count(*) from link$;
exit
