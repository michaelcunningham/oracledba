set pages 200
select object_type,count(distinct object_name) SUM_TDB_1 from verify_consolidate where db_name in ('TDB00','TDB01','TDB02','TDB03','TDB04','TDB05','TDB06','TDB07')
and object_name not like 'JMK_TEMP%'
group by object_type
order by 1
/
select object_type,count(*) CONS_TDB01 from verify_consolidate where db_name='NEW_TDB01'
group by object_type
order by 1
/
select object_type,count(distinct object_name) SUM_TDB_2 from verify_consolidate where db_name in ('TDB08','TDB09','TDB10','TDB11','TDB12','TDB13','TDB14','TDB15')
and object_name not like 'JMK_TEMP%'
group by object_type
order by 1
/
select object_type,count(*) CONS_TDB02 from verify_consolidate where db_name='NEW_TDB02'
group by object_type
order by 1
/
select object_type,count(distinct object_name) SUM_TDB_3 from verify_consolidate where db_name in ('TDB16','TDB17','TDB18','TDB19','TDB20','TDB21','TDB22','TDB23')
and object_name not like 'JMK_TEMP%'
group by object_type
order by 1
/
select object_type,count(*) CONS_TDB03 from verify_consolidate where db_name='NEW_TDB03'
group by object_type
order by 1
/
select object_type,count(distinct object_name) SUM_TDB_4 from verify_consolidate where db_name in ('TDB24','TDB25','TDB26','TDB27','TDB28','TDB29','TDB30','TDB31')
and object_name not like 'JMK_TEMP%'
group by object_type
order by 1
/
select object_type,count(*) CONS_TDB04 from verify_consolidate where db_name='NEW_TDB04'
group by object_type
order by 1
/

