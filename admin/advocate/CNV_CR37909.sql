declare
    cursor occur_cur is
        select * 
        from user_tab_columns 
        where column_name like '%OCCUR_NUM%';
begin
    for occur_row in occur_cur loop
        execute immediate('update ' || occur_row.table_name || ' set ' || occur_row.column_name || ' = ltrim('  || occur_row.column_name || ')');   
    end loop;
    commit;
end;
/

