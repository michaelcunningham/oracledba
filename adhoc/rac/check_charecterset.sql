set pages 100
set lines 200
col parameter format a40
col value format a40
col value$ format a40
SELECT * FROM NLS_DATABASE_PARAMETERS;
SELECT value$ FROM sys.props$ WHERE name ='NLS_CHARACTERSET' ;
