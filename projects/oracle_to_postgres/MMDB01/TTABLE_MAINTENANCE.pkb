CREATE OR REPLACE PACKAGE BODY TAG.ttable_maintenance is

PROCEDURE truncate_t_tables(intable in varchar2) AS
 ssql varchar2(1000);
  unused_t_table number(2);
  unused_t_table_name varchar2(30);
  t_count number:=0;
  sample_partition number(2);
  BEGIN
        select min(partition_no) into sample_partition from pdb_layout where pdb=sys_context('userenv','instance_name');
        select count(*) into t_count from user_tables where table_name like upper(intable)||'_T%'||'_P'||sample_partition;
        If t_count=0 then
	   ssql:='no tables with that name found'||upper(intable)||'_T%'||'_P'||sample_partition;
	   insert into ttable_audit(action) values(ssql);
	   commit;
	else
   		 select mod(( to_char(sysdate, 'yyyy') * 12 + to_char(sysdate, 'mm')) + 1, t_count) INTO unused_t_table from dual;

   		 unused_t_table_name:=upper(intable)||'_T'||unused_t_table||'_P%';
   		 for i in (select table_name from user_tables where table_name like unused_t_table_name)
   			LOOP
        		ssql:='truncate table '||i.table_name;
        		insert into ttable_audit(action) values(ssql);
        		commit;
  			execute immediate ssql;
   			END LOOP;
	end if;
   END truncate_t_tables;

PROCEDURE check_t_tables(intable in varchar2) as
 ssql varchar2(1000);
  unused_t_table number(2);
  unused_t_table_name varchar2(30);
  t_count number:=0;
 final_count number:=0;
  sample_partition number(2);
  BEGIN
        select min(partition_no) into sample_partition from pdb_layout where pdb=sys_context('userenv','instance_name');
        select count(*) into t_count from user_tables where table_name like upper(intable)||'_T%'||'_P'||sample_partition;
        If t_count=0 then
           ssql:='no tables with that name found'||upper(intable)||'_T%'||'_P'||sample_partition;
           insert into ttable_audit(action) values(ssql);
           commit;
        else
                 select mod(( to_char(sysdate, 'yyyy') * 12 + to_char(sysdate, 'mm')) + 1, t_count) INTO unused_t_table from dual;

                 unused_t_table_name:=upper(intable)||'_T'||unused_t_table||'_P%';
                 for i in (select table_name from user_tables where table_name like unused_t_table_name)
                        LOOP
			ssql:='select count(*) from '||i.table_name;
			execute immediate ssql into final_count;
			if final_count != 0 then
			    insert into ttable_audit(action) values ('Count is not zero for '||ssql);
			    commit;
			end if;
			end loop;
	end if;

 end check_t_tables;
   end;
/