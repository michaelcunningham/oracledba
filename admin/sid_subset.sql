select s.username, s.osuser, s.status,
SUBSTR( NVL( s.module, s.program ), 1, 40 ) Program, s.machine
FROM   v$session s
WHERE  s.username IS NOT NULL
AND    s.type <> 'BACKGROUND'
order by s.username
/
~

