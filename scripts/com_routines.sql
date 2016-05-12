------------------------------------------------------------------------------
--  Common shared procedures script.
--
--  Version Date        Description
--  ================================================================
--  2.0     Jan 1999    Initial version of this script file.
--                      J. Lopatosky

-------------------------------------------------------------------------------
FUNCTION strip (
   i_text IN LONG )
  RETURN LONG IS
  o_text LONG := NULL;
BEGIN
  o_text := LTRIM(RTRIM(i_text));
RETURN o_text;
END ;

-------------------------------------------------------------------------------
FUNCTION format_date (
  i_date IN DATE )
  RETURN VARCHAR2 IS
  o_date VARCHAR2(30) := NULL;
BEGIN
  o_date := TO_CHAR(i_date,'Mon DD, YYYY HH24:MI:SS');
RETURN o_date;
END ;

-------------------------------------------------------------------------------
FUNCTION format_percent (
  i_percent IN NUMBER )
  RETURN VARCHAR2 IS
  o_percent VARCHAR2(30) := NULL;
BEGIN
  o_percent := TO_CHAR(i_percent*100,'990.99');
RETURN o_percent;
END ;

-------------------------------------------------------------------------------
FUNCTION format_object_name (
  i_object_name IN VARCHAR2 )
  RETURN VARCHAR2 IS
  o_object_name VARCHAR2(30) := NULL;
BEGIN
  o_object_name := LOWER(i_object_name);
RETURN o_object_name;
END ;

-------------------------------------------------------------------------------
FUNCTION format_file_name (
  i_file_name IN VARCHAR2 )
  RETURN VARCHAR2 IS
  o_file_name VARCHAR2(2000) := NULL;
BEGIN
  o_file_name := RPAD(i_file_name,60);
RETURN o_file_name;
END ;

-------------------------------------------------------------------------------
PROCEDURE display_line (
  i_display_line IN LONG
  ) IS
BEGIN
  dbms_output.put_line(i_display_line);
END ;

-------------------------------------------------------------------------------
PROCEDURE display_line IS
BEGIN
   display_line('');
END ;

-------------------------------------------------------------------------------
PROCEDURE display_report_detail_line (
  i_line_to_display VARCHAR2
  ) IS
BEGIN
  display_line(i_line_to_display);
  v_line_number := v_line_number + 1;
END;

-------------------------------------------------------------------------------
PROCEDURE display_report_heading IS

v_max_header_length NUMBER := 0;

BEGIN

  IF v_page_number > 0 THEN
    display_report_detail_line('');
    display_report_detail_line('');
  END IF;
  
  FOR v_repthead_index IN 1..v_repthead_index_max LOOP
    display_report_detail_line(report_header_tab(v_repthead_index).header_line);
    IF LENGTH(report_header_tab(v_repthead_index).header_line) > v_max_header_length THEN
      v_max_header_length := LENGTH(report_header_tab(v_repthead_index).header_line);
    END IF;
  END LOOP;
  
  v_display_temp := RPAD('-',v_max_header_length,'-');
  display_report_detail_line(v_display_temp);

  v_line_number := 0;
  v_page_number := v_page_number + 1;

END;

-------------------------------------------------------------------------------
PROCEDURE display_runtime IS
BEGIN
  display_line;
  display_line('Execution Timestamp: ' || format_date(sysdate));
  display_line;
END;

-------------------------------------------------------------------------------
PROCEDURE capture_time IS
BEGIN
  v_previous_timing := v_current_timing;
  v_current_timing := dbms_utility.get_time;
END ;

-------------------------------------------------------------------------------
PROCEDURE display_elapsed_time IS
BEGIN
  display_line('Elapsed Time (seconds): ' ||
               TO_CHAR((v_current_timing - v_previous_timing)/100,'9990D99'));
END ;

-------------------------------------------------------------------------------
PROCEDURE run_dynamic_sql_no_rows (
  i_sql IN VARCHAR2
  ) IS
  v_dynamic_cursor INTEGER := NULL;
  v_rows_processed INTEGER := NULL;
BEGIN
--  Prep work. Open, parse, and execute the sql.
  v_dynamic_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(v_dynamic_cursor, i_sql, dbms_sql.native);
  dbms_sql.close_cursor(v_dynamic_cursor);

EXCEPTION
  WHEN Others THEN
      IF dbms_sql.Is_Open(v_dynamic_cursor) THEN
          dbms_sql.close_cursor(v_dynamic_cursor);
      END IF;
  RAISE;
END ;

-------------------------------------------------------------------------------
PROCEDURE run_dynamic_sql (
  i_sql IN VARCHAR2
  ) IS
  v_dynamic_cursor INTEGER := NULL;
  v_rows_processed INTEGER := NULL;
BEGIN
--  Prep work. Open, parse, and execute the sql.
  v_dynamic_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(v_dynamic_cursor, i_sql, dbms_sql.native);
  dbms_sql.define_column(v_dynamic_cursor, 1, v_sql_result, 2000);
  v_rows_processed := dbms_sql.execute(v_dynamic_cursor);

--  Loop through the returned rows.
  loop
    if dbms_sql.fetch_rows(v_dynamic_cursor) > 0 then
      dbms_sql.column_value(v_dynamic_cursor, 1, v_sql_result);
    else
      exit;
    end if;
  end loop;
  dbms_sql.close_cursor(v_dynamic_cursor);

EXCEPTION
  WHEN Others THEN
      IF dbms_sql.Is_Open(v_dynamic_cursor) THEN
          dbms_sql.close_cursor(v_dynamic_cursor);
      END IF;
  RAISE;
END ;

-------------------------------------------------------------------------------
FUNCTION check_oracle_version
  RETURN VARCHAR2 IS

BEGIN
--  This utility is not available until version 8.
-- dbms_utility.db_version(o_db_version,o_db_compatibility);

-- Get version information from database
  v_sql := 'SELECT banner'
        || '  FROM v$version'
        || ' WHERE banner LIKE ''Oracle%'' ';
  run_dynamic_sql(v_sql);
  v_db_version := SUBSTR(v_sql_result,INSTR(v_sql_result,'Release ')+8);
  v_db_version := SUBSTR(v_db_version,1,INSTR(v_db_version,' ')-1);
  o_db_version := v_db_version;
RETURN o_db_version;

END ;

-------------------------------------------------------------------------------
FUNCTION calc_date_diff (
   i_date_1 IN DATE
  ,i_date_2 IN DATE
  )
  RETURN VARCHAR2 IS

  v_diff_temp NUMBER := 0;
  v_diff_days NUMBER := 0;
  v_diff_hours NUMBER := 0;
  v_diff_mins NUMBER := 0;
  v_diff_secs NUMBER := 0;
  o_diff VARCHAR2(30) := NULL;
  
BEGIN
--  Compute the difference in raw days.
  v_diff_temp := i_date_1 - i_date_2;
  
  IF v_diff_temp <> 0 THEN
    --  Strip out the number of days.
    v_diff_days := TRUNC(v_diff_temp);
  
    --  Calculate and strip out the number of hours.
    v_diff_temp := (v_diff_temp - v_diff_days)*24;
    v_diff_hours := TRUNC(v_diff_temp);
  
    --  Calculate and strip out the number of minutes.
    v_diff_temp := (v_diff_temp - v_diff_hours)*60;
    v_diff_mins := TRUNC(v_diff_temp);
  
    --  Calculate and strip out the number of seconds.
    v_diff_temp := (v_diff_temp - v_diff_mins)*60;
    v_diff_secs := TRUNC(v_diff_temp);

    o_diff := TO_CHAR(v_diff_days,'B999') || ' '
           || LPAD(v_diff_hours,2,0) || ':' 
           || LPAD(v_diff_mins,2,0) || ':'
           || LPAD(v_diff_secs,2,0);
  END IF;
         
RETURN o_diff;

END ;

-------------------------------------------------------------------------------
PROCEDURE build_data_type (
   i_data_type IN VARCHAR2
  ,i_data_precision IN VARCHAR2
  ,i_data_scale IN VARCHAR2
  ,i_data_length IN VARCHAR2
  ,o_data_type OUT VARCHAR2
  ) IS

  v_temp_type VARCHAR2(30);

BEGIN
  v_temp_type := i_data_type;
  IF i_data_type = 'NUMBER' THEN
    IF i_data_precision > 0 THEN
      v_temp_type := v_temp_type || '(' || i_data_precision ||
                     ',' || i_data_scale || ')';
    END IF;
  ELSIF i_data_type NOT IN ('DATE','LONG','LONG RAW') THEN
    v_temp_type := v_temp_type || '(' || i_data_length || ')';
  END IF;
  o_data_type := v_temp_type;

END ;

-------------------------------------------------------------------------------
PROCEDURE build_default (
   i_data_default IN VARCHAR2
  ,o_data_default OUT VARCHAR2
  ) IS
BEGIN
  IF LENGTH(i_data_default) > 0 THEN
    --  This strips out trailing carriage returns...hopefully, nothing else.
    o_data_default := 'DEFAULT ' || SUBSTR(STRIP(i_data_default),1,LENGTH(i_data_default)-1) || ' ';
  ELSE
    o_data_default := '';
  END IF;
END ;

-------------------------------------------------------------------------------
PROCEDURE build_nullable (
   i_nullable IN VARCHAR2
  ,o_nullable OUT VARCHAR2
  ) IS
BEGIN
  IF i_nullable = 'Y' THEN
    o_nullable := '        ';
  ELSE
    o_nullable := 'NOT NULL';
  END IF;
END ;

-------------------------------------------------------------------------------
PROCEDURE parse_text (
   i_text IN VARCHAR2
  ,i_delimiter IN VARCHAR2
  ,o_delimiter_found OUT BOOLEAN
  ,o_text_parse OUT VARCHAR2
  ,o_text_rest OUT VARCHAR2
  ) IS
  v_first_delimiter_occur NUMBER;
BEGIN
  o_text_parse := NULL;
  o_text_rest := NULL;
  v_first_delimiter_occur := INSTR(i_text,i_delimiter, 1);
  IF v_first_delimiter_occur > 0 THEN
    o_text_parse := SUBSTR(i_text, 1, v_first_delimiter_occur - 1);
    o_text_rest := SUBSTR(i_text, v_first_delimiter_occur + 1);
    o_delimiter_found := TRUE;
  ELSE
    o_text_parse := i_text;
    o_text_rest := NULL;
    o_delimiter_found := FALSE;
  END IF;
END ;

-------------------------------------------------------------------------------
PROCEDURE format_sql (
  i_text IN LONG
  ) IS

-- outer loop variables
v_text LONG;
v_text_parse LONG;
v_text_rest LONG;
v_delimiter_found BOOLEAN := TRUE;

-- inner loop variables
v_text_inner LONG;
v_text_parse_inner LONG;
v_text_rest_inner LONG;
v_delimiter_found_inner BOOLEAN := TRUE;

c_eol CONSTANT VARCHAR2(1) := CHR(10);
c_comma CONSTANT VARCHAR2(1) := ',';
c_max_line_size CONSTANT NUMBER := 100;
c_min_line_size CONSTANT NUMBER := 0;

BEGIN

  v_text := RTRIM(i_text);
--  Parse for each Linefeed / Carriage return.  This causes
--  Lines to be dislayed as they were typed in.
  WHILE v_delimiter_found LOOP
    parse_text(
       v_text
      ,c_eol
      ,v_delimiter_found
      ,v_text_parse
      ,v_text_rest
      );
--  Sometimes, the first part is too large to fit on a display line.
--  If this is the case, try parsing by something else (,).
    IF LENGTH(strip(v_text_parse)) > c_max_line_size THEN
      v_text_inner := v_text_parse;
      WHILE v_delimiter_found_inner LOOP
        parse_text(
           v_text_inner
          ,c_comma
          ,v_delimiter_found_inner
          ,v_text_parse_inner
          ,v_text_rest_inner
          );
        IF v_delimiter_found_inner THEN
          display_line(v_text_parse_inner || c_comma);
        ELSE
          display_line(v_text_parse_inner);
        END IF;
        v_text_inner := v_text_rest_inner;
      END LOOP;
      v_text_parse := NULL;
    END IF;

    IF LENGTH(strip(v_text_parse)) > c_min_line_size THEN
      display_line(v_text_parse );
    END IF;
    v_text := v_text_rest;
  END LOOP;

END;

-------------------------------------------------------------------------------
--   End of script com_routines.sql                                        --
-------------------------------------------------------------------------------

