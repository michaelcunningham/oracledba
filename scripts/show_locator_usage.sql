set linesize 160
set pagesize 100

SELECT name,
detected_usages
FROM dba_feature_usage_statistics
WHERE Upper(name) LIKE '%LOCAT%'
/

SELECT name,
detected_usages
FROM dba_feature_usage_statistics
WHERE Upper(name) LIKE '%SPATIA%'
/
