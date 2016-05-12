begin
for r in( select replace( rollback_sql_stmt, ';' ) sql_text from db_schema_obj_to_drop )
loop
execute immediate r.sql_text;
end loop;
end;
/
