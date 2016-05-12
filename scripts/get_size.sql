set verify off
set serveroutput on
declare
	s_segment_owner			varchar2(30);
	s_segment_name			varchar2(30);
	s_segment_type			varchar2(30);
	n_total_blocks			number;
	n_total_bytes			number;
	n_unused_blocks			number;
	n_unused_bytes			number;
	n_last_used_extent_file_id	number;
	n_last_used_extent_block_id	number;
	n_last_used_block		number;
	n_free_blks			number;
begin
	s_segment_owner := UPPER( '&1' );
	s_segment_name := UPPER( '&2' );

	SELECT	segment_type
	INTO	s_segment_type
	FROM	dba_segments
	WHERE	owner = s_segment_owner
	AND	segment_name = s_segment_name;

	dbms_space.unused_space( s_segment_owner, s_segment_name, s_segment_type,
		n_total_blocks, n_total_bytes, n_unused_blocks,
		n_unused_bytes, n_last_used_extent_file_id, n_last_used_extent_block_id,
		n_last_used_block );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '	Space usage report for ' || s_segment_type || ': ' || s_segment_name );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Total Blocks                   : ' || to_char( n_total_blocks, '999,999,999,990' ) );
	dbms_output.put_line( 'Total Bytes                    : ' || to_char( n_total_bytes, '999,999,999,990' ) );
	dbms_output.put_line( 'Unused Blocks (never had data) : ' || to_char( n_unused_blocks, '999,999,999,990' ) );
	dbms_output.put_line( 'Unused Bytes                   : ' || to_char( n_unused_bytes, '999,999,999,990' ) );
	dbms_output.put_line( 'Last Used Extent File ID       : ' || to_char( n_last_used_extent_file_id, '999,999,999,990' ) );
	dbms_output.put_line( 'Last Used Extent Block ID      : ' || to_char( n_last_used_extent_block_id, '999,999,999,990' ) );
	dbms_output.put_line( 'Last Used Block (in extent)    : ' || to_char( n_last_used_block, '999,999,999,990' ) );

	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Blocks in use                  : ' || to_char( n_total_blocks-n_unused_blocks, '999,999,999,990' ) );

--	dbms_space.free_blocks( s_segment_owner, s_segment_name, s_segment_type,
--		0, n_free_blks );

--	dbms_output.put_line( '	' );
--	dbms_output.put_line( 'Free Blocks (on free list)     : ' || to_char( n_free_blks, '999,999,999,990' ) );

end;
/
