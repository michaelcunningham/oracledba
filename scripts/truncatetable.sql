-- File:     truncatetable.sql
--
-- Purpose:  Truncate a table.
--           The advantage of this script is it will first disable all child
--           foreign key constraints, truncate the table, then reenable
--           the constraints.
--
-- Usage:    SQL >truncatetable  <table_name>

@@dischildfk &1
truncate table &1;
@@enchildfk &1
undef 1
