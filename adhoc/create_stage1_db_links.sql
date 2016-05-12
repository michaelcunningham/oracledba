create public database link TAGDB connect to tag identified by zx6j1bft using 'TAGDB';

create public database link MMDB01 connect to tag identified by zx6j1bft using 'MMDB01';

create public database link MMDB02 connect to tag identified by zx6j1bft using 'MMDB02';

create public database link WHSE connect to tag identified by zx6j1bft using 'WHSE';

create public database link WHSE_TAGANALYSIS connect to taganalysis identified by "$taganalysis$" using 'WHSE';

create public database link DEVTAGDB connect to tag identified by zx6j1bft using 'DEVTAGDB';


declare
	s_sql	varchar2(500);
begin
	for i in 1..8 loop
		s_sql := 'create public database link PDB' || lpad( i, 2, '0' );
		s_sql := s_sql || ' connect to tag identified by zx6j1bft using ''PDB' || lpad( i, 2, '0' ) || '''';
		dbms_output.put_line( s_sql || ';' );
		execute immediate s_sql;
	end loop;
end;
/

declare
	s_sql	varchar2(500);
begin
	for i in 1..8 loop
		s_sql := 'create public database link STGPRT' || lpad( i, 2, '0' );
		s_sql := s_sql || ' connect to tag identified by zx6j1bft using ''STGPRT' || lpad( i, 2, '0' ) || '''';
		dbms_output.put_line( s_sql || ';' );
		execute immediate s_sql;
	end loop;
end;
/

declare
	s_sql	varchar2(500);
begin
	for i in 1..8 loop
		s_sql := 'create public database link DEVPDB' || lpad( i, 2, '0' );
		s_sql := s_sql || ' connect to tag identified by zx6j1bft using ''DEVPDB' || lpad( i, 2, '0' ) || '''';
		dbms_output.put_line( s_sql || ';' );
		execute immediate s_sql;
	end loop;
end;
/

declare
	s_sql	varchar2(500);
begin
	for i in 0..63 loop
		s_sql := 'create public database link TDB' || lpad( i, 2, '0' );
		s_sql := s_sql || ' connect to tag identified by zx6j1bft using ''TDB' || lpad( i, 2, '0' ) || '''';
		dbms_output.put_line( s_sql || ';' );
		execute immediate s_sql;
	end loop;
end;
/

declare
	s_sql	varchar2(500);
begin
	for i in 0..63 loop
		s_sql := 'create public database link STDB' || lpad( i, 2, '0' );
		s_sql := s_sql || ' connect to tag identified by zx6j1bft using ''STDB' || lpad( i, 2, '0' ) || '''';
		dbms_output.put_line( s_sql || ';' );
		execute immediate s_sql;
	end loop;
end;
/

declare
	s_sql	varchar2(500);
begin
	for i in 0..63 loop
		s_sql := 'create public database link DTDB' || lpad( i, 2, '0' );
		s_sql := s_sql || ' connect to tag identified by zx6j1bft using ''DTDB' || lpad( i, 2, '0' ) || '''';
		dbms_output.put_line( s_sql || ';' );
		execute immediate s_sql;
	end loop;
end;
/
