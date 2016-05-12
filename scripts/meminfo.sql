set serveroutput on
set linesize 130
declare
	n_buffer_cache_size	int;
	n_sga_max_size		int;
	n_db_cache_size		int;
	n_db_2k_cache_size	int;
	n_db_4k_cache_size	int;
	n_db_8k_cache_size	int;
	n_db_16k_cache_size	int;
	n_db_32k_cache_size	int;
	n_db_keep_cache_size	int;
	n_db_recycle_cache_size	int;
	n_shared_pool_size	int;
	n_large_pool_size	int;
	n_java_pool_size	int;
	n_streams_pool_size	int;
	n_shared_io_pool	int;
	n_ksmg_granule_size	int;
begin
	select value into n_db_cache_size from v$parameter where name = 'db_cache_size';
	select value into n_db_2k_cache_size from v$parameter where name = 'db_2k_cache_size';
	select value into n_db_4k_cache_size from v$parameter where name = 'db_4k_cache_size';
	select value into n_db_8k_cache_size from v$parameter where name = 'db_8k_cache_size';
	select value into n_db_16k_cache_size from v$parameter where name = 'db_16k_cache_size';
	select value into n_db_32k_cache_size from v$parameter where name = 'db_32k_cache_size';
	select value into n_db_keep_cache_size from v$parameter where name = 'db_keep_cache_size';
	select value into n_db_recycle_cache_size from v$parameter where name = 'db_recycle_cache_size';

	select	sum( value )
	into	n_buffer_cache_size
	from	(
		select	name, value, display_value
		from	v$parameter
		where	name in( 'db_cache_size', 'db_2k_cache_size', 'db_4k_cache_size',
				'db_8k_cache_size', 'db_16k_cache_size', 'db_32k_cache_size',
				'db_keep_cache_size', 'db_recycle_cache_size' )
		order by type, num );

	select value into n_shared_pool_size from v$parameter where name = 'shared_pool_size';
	select value into n_large_pool_size from v$parameter where name = 'large_pool_size';
	select value into n_java_pool_size from v$parameter where name = 'java_pool_size';
	select value into n_streams_pool_size from v$parameter where name = 'streams_pool_size';
	select nvl( max( bytes ), 0 ) into n_shared_io_pool from v$sgastat where name = 'shared_io_pool';
	select nvl( max( value ), 0 ) into n_ksmg_granule_size from v$parameter where name = '_ksmg_granule_size';
	select y.ksppstvl into n_ksmg_granule_size from x$ksppi x, x$ksppcv y
	where x.indx = y.indx and x.ksppinm = '_ksmg_granule_size';

	select	sum( value ) + n_buffer_cache_size + n_shared_io_pool + n_ksmg_granule_size
	into	n_sga_max_size
	from	(
		select	name, value, display_value
		from	v$parameter
		where	name in( 'shared_pool_size', 'large_pool_size', 'java_pool_size', 'streams_pool_size' )
		order by type, num );

	dbms_output.put_line( '****************************************************************************************************' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'The following is a detailed report of how much memory is being used by oracle.' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Buffer Cache Size =' );
	dbms_output.put_line( '	  db_cache_size           ' || to_char( n_db_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ db_2k_cache_size        ' || to_char( n_db_2k_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ db_4k_cache_size        ' || to_char( n_db_4k_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ db_8k_cache_size        ' || to_char( n_db_8k_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ db_16k_cache_size       ' || to_char( n_db_16k_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ db_32k_cache_size       ' || to_char( n_db_32k_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ db_keep_cache_size      ' || to_char( n_db_keep_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ db_recycle_cache_size   ' || to_char( n_db_recycle_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	                           ---------------' );
	dbms_output.put_line( '	                          ' || to_char( n_buffer_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'SGA Max Size =' );
	dbms_output.put_line( '	  Buffer Cache Size       ' || to_char( n_buffer_cache_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ shared_pool_size        ' || to_char( n_shared_pool_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ large_pool_size         ' || to_char( n_large_pool_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ java_pool_size          ' || to_char( n_java_pool_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ streams_pool_size       ' || to_char( n_streams_pool_size, '999,999,999,999' ) );
	dbms_output.put_line( '	+ shared_io_pool          ' || to_char( n_shared_io_pool, '999,999,999,999' ) || '	<< only on 12c' );
	dbms_output.put_line( '	+ _ksmg_granule_size      ' || to_char( n_ksmg_granule_size, '999,999,999,999' ) );
	dbms_output.put_line( '	                           ---------------' );
	dbms_output.put_line( '	                          ' || to_char( n_sga_max_size, '999,999,999,999' ) );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Summary' );
	dbms_output.put_line( 'Parameter                         Bytes     GBytes' );
	dbms_output.put_line( '-------------------  ------------------  ---------' );
	dbms_output.put_line( 'Buffer Cache Size      ' || to_char( n_buffer_cache_size, '999,999,999,999' )
		|| to_char( n_buffer_cache_size/1024/1024/1024, '999,990.00' ) );
	dbms_output.put_line( 'SGA Max Size           ' || to_char( n_sga_max_size, '999,999,999,999' )
		|| to_char( n_sga_max_size/1024/1024/1024, '999,990.00' ) || ' (Max allowed by Oracle 10gR2 is 168 GB)' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '****************************************************************************************************' );
end;
/


