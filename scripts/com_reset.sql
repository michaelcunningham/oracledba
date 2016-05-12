-------------------------------------------------------------------------------
--  Common reset of the SQL*Plus environment.
--
--  Version Date        Description
--  ================================================================
--  2.0     Jan 1999    Initial version of this script file.
--                      J. Lopatosky

--  Reset the SQL*Plus settings.
-- @sqlenv

--  Delete the settings file.
-- host del sqlenv.sql

set trimspool on
set feedback on
set timing on
set verify on
set heading on
set termout on

clear columns
clear breaks
clear computes
ttitle off
btitle off

-------------------------------------------------------------------------------
--   End of script com_set.sql                                               --
-------------------------------------------------------------------------------
