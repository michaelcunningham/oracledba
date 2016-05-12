set linesize 160
set pagesize 100

column db_unique_name	format a10
column feature_name	format a40
column detected_usages	format 999,999
column compression_info	format a30

alter session set nls_date_format='YYYY-MM-DD HH24:MI';

SET HEADING OFF
SET FEEDBACK OFF
PROMPT *** SPATIAL
PROMPT ======================================================================
select 'ORACLE SPATIAL INSTALLED: ' || VALUE from V$OPTION where PARAMETER='Spatial';
SET HEADING ON
SET FEEDBACK ON
PROMPT CHECKING TO SEE IF SPATIAL FUNCTIONS ARE BEING USED...
select count(*) as SDO_GEOM_METADATA_TABLE
  from MDSYS.SDO_GEOM_METADATA_TABLE;
PROMPT If value returned is 0, then SPATIAL is NOT being used.
PROMPT If value returned is > 0, then SPATIAL OR LOCATOR IS being used.

