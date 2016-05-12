set termout off
whenever sqlerror exit 1
--select * from dual;
select count(*) from link$;
exit
