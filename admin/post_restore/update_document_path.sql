set serveroutput on size 1000000
set linesize 120
prompt

alter table ed_document disable all triggers;

declare
	s_document_file_path	ed_document.document_file_path%type;
begin
	dbms_output.put_line( '*** Updating DOCUMENT_FILE_PATH values ***' || CHR(10) );

	select	document_file_path
	into	s_document_file_path
	from	aa_sys_config;

	update	ed_document
	set	document_file_path = s_document_file_path
	where	upper( substr( document_file_path, -4 ) ) <> 'MAIL'
	and	document_file_path <> s_document_file_path;

	dbms_output.put_line( 'ED_DOCUMENT.DOCUMENT_FILE_PATH had ' || SQL%ROWCOUNT
		|| ' rows updated with ' || s_document_file_path || '.' );

	update	ed_document
	set	document_file_path = s_document_file_path || 'mail'
	where	upper( substr( document_file_path, -4 ) ) = 'MAIL'
	and     document_file_path <> s_document_file_path || 'mail';

	dbms_output.put_line( 'ED_DOCUMENT.DOCUMENT_FILE_PATH had ' || SQL%ROWCOUNT
		|| ' rows updated with ' || s_document_file_path || 'mail' );

-- update ed_outbound_document set pitney_bowes_status_id = 'DM' 
-- where pitney_bowes_status_id = 'NA';

end;
/

alter table ed_document enable all triggers;

commit;
prompt
