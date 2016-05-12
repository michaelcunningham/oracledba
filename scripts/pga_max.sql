set linesize 124
column name format a40
column value format a80

select	name, to_char( value, '999,999,999,999,999,999' ) value from v$pgastat
where	name in( 'maximum PGA allocated', 'aggregate PGA target parameter',
		'over allocation count', 'extra bytes read/written',
		'maximum PGA used for auto workareas', 'total PGA allocated',
		'total PGA inuse' )
order by 1;
