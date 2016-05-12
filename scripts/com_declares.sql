-------------------------------------------------------------------------------
--  Common Pl/Sql DECLARE statements.
--
--  Version Date        Description
--  ================================================================
--  2.0     Jan 1999    Initial version of this script file.
--                      J. Lopatosky

--  c_sql_comment CONSTANT VARCHAR2(3)    := '-- ';
--  c_no_data CONSTANT VARCHAR2(1) := ' ';
  v_db_version v$version.banner%TYPE;
  o_db_version v$version.banner%TYPE;
--  o_db_compatibility VARCHAR2(12)    := NULL;
--  v_data_temp VARCHAR2(30) := NULL;
  v_current_timing NUMBER := NULL;
  v_previous_timing NUMBER := NULL;
--  v_varchar2_temp VARCHAR2(30) := NULL;
----  Used by the display_line routines.
  v_display_line VARCHAR2(2000) := NULL;
  v_display_temp VARCHAR2(2000) := NULL;
----  Used by the dynamic SQL routines.
  v_sql VARCHAR2(2000) := NULL;
  v_sql_result VARCHAR2(2000) := NULL;
----  Report controls.
--  v_lines_per_page NUMBER := 55;
  v_line_number NUMBER := NULL;
  v_page_number NUMBER := 0;
--  v_repthead_index BINARY_INTEGER := 0;
  v_repthead_index_max BINARY_INTEGER := 0;
--
TYPE report_header_rectype IS RECORD (
   header_line      VARCHAR2(2000)
  )
;
--
TYPE report_header_tabtype IS TABLE OF report_header_rectype
  INDEX BY BINARY_INTEGER;
--
report_header_tab  report_header_tabtype;


-------------------------------------------------------------------------------
--   End of script com_declares.sql                                          --
-------------------------------------------------------------------------------
