-------------------------------------------------------------------------------
--  Common setup of the SQL*Plus environment.
--
--  Version Date        Description
--  ================================================================
--  2.0     Jan 1999    Initial version of this script file.
--                      J. Lopatosky

-- set termout off
--  Save the SQL-Plus settings
-- store set sqlenv rep
-- set termout on

clear columns
clear breaks
clear computes
ttitle off
btitle off

set serveroutput on size 1000000 format wrapped
set trimspool on
set feedback off
set timing off
set verify off
set heading off

-- set termout off


-------------------------------------------------------------------------------
--   End of script com_set.sql                                               --
-------------------------------------------------------------------------------
