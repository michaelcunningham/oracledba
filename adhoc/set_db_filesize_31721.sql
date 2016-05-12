set serveroutput on
begin
	for r in(
       		select	'alter database datafile ''' || file_name || ''' resize 30721M' sql_text
       		from	dba_data_files ddf
		where	trunc( bytes/1024/1024 ) = 30720 )
	loop
		dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
end;
/

