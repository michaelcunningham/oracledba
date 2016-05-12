rem http://www.dbaglobe.com/2009/09/how-to-get-oracle-hidden-underscore.html
SELECT
  x.ksppinm name,
  y.ksppstvl VALUE,
  decode(ksppity,
    1,   'BOOLEAN',
    2,   'STRING',
    3,   'INTEGER',
    4,   'PARAMETER FILE',
    5,   'RESERVED',
    6,   'BIG INTEGER',
    'UNKNOWN') typ,
  decode(ksppstdf,
    'TRUE',   'DEFAULT VALUE',
    'FALSE',   'INIT.ORA') isdefault,
  decode(bitand(ksppiflg / 256,   1),
    1,   'IS_SESS_MOD(TRUE)',
    'FALSE') isses_modifiable,
  decode(bitand(ksppiflg / 65536,   3),
    1,   'MODSYS(NONDEFERED)',
    2,   'MODSYS(DEFERED)',
    3,   'MODSYS(*NONDEFERED*)',
    'FALSE') issys_modifiable,
  decode(bitand(ksppstvf,   7),
    1,   'MODIFIED_BY(SESSION)',
    4,   'MODIFIED_BY(SYSTEM)',
    'FALSE') is_modified,
  decode(bitand(ksppstvf,   2),
    2,   'ORA_STARTUP_MOD(TRUE)',
    'FALSE') is_adjusted,
  ksppdesc description,
  ksppstcmnt update_comment
FROM x$ksppi x,
  x$ksppcv y
WHERE x.inst_id = userenv('Instance')
 AND y.inst_id = userenv('Instance')
 AND x.indx = y.indx
 AND x.ksppinm LIKE '%&param%';
