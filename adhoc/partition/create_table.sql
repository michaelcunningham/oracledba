CREATE TABLE test_part (
    id	NUMBER,
	data  VARCHAR2(100)
)
PARTITION BY RANGE(id) ( -- Partion Key = Primary Key
	PARTITION test_part_1 VALUES LESS THAN (MAXVALUE)
);

CREATE TABLE test_part_temp(
    id  NUMBER,
        data  VARCHAR2(100)
);

insert into test_part_temp(id) select distinct thread_id from messages where rownum<1000;
commit;

alter table test_part add constraint pk_test_part primary key(id)
using index ( create index pk_test_part on test_part(id) local);

alter table test_part_temp add constraint pk_test_part_temp primary key(id)
using index ( create index pk_test_part_temp on test_part_temp(id));

alter table test_part exchange partition test_part_1 with table test_part_temp
including indexes
without validation;

 select index_name,status,partition_name from user_ind_partitions
where partition_name='TEST_PART_1';





