--
-- This should be done after the create_nastats_objects.sh file
-- has been edited and ran.
-- That file needs to run so the external table is created for
-- the correct perfstat output file.
--
connect lmon/lmon@//npdb520.tdc.internal:1529/apex.tdc.internal

alter table perfstat_log_file location ( 'perfstat_npnetapp108_180_20111216_2218.log' );
-- delete from perfstat_log;

declare
	s_filer_name	varchar2(20);
begin
	select	substr(log_text,1,instr(log_text,' ')-1)
	into	s_filer_name
	from	perfstat_log_file
	where	log_text like '%self%';

	insert into perfstat_log(
		filer, log_text, name, full_value, created_date, parsed )
	select	s_filer_name, log_text,
		substr( log_text, 1, instr( log_text, ':', -1 ) - 1 ),
		substr( log_text, instr( log_text, ':', -1 ) + 1 ),
		trunc(sysdate-2), 'Y'
	from	(
		select	distinct log_text
		from	perfstat_log_file
		where	log_text is not null
		and	log_text in(
				select	log_text
				from	perfstat_name
				where	log_text like name || '%'
				and	report_level <= 1 )
		);
	commit;
end;
/

exit;
