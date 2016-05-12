#!/bin/sh

tns=//npdb520.tdc.internal:1529/apex.tdc.internal
username=lmon
userpwd=lmon

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/listener_log/log/${ORACLE_SID}_listener_log.log

echo ...................... parsing listener log data

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

set term off
set feedback off

declare
	s_program_name	listener_log.program_name%type;
	s_user_name	listener_log.user_name%type;
	s_host_name	listener_log.host_name%type;
	s_host_ip	listener_log.host_ip%type;
	s_host_port	listener_log.host_port%type;
	s_work		listener_log.log_text%type;
	n_start		integer;
	n_equal		integer;
	n_end		integer;
begin
	for r in(
		select	id, log_text
		from	listener_log
		where	parsed = 'N' )
	loop
		--
		-- Find the name of the program
		--
		n_start := instr( r.log_text, 'PROGRAM' );
		s_work := substr( r.log_text, n_start );
		n_equal := instr( s_work, '=' );
		n_end := instr( s_work, ')' );

		s_program_name := substr( s_work, n_equal+1, n_end-n_equal-1 );

		--
		-- Find the name of the USER.
		--
		n_start := instr( r.log_text, 'USER' );
		s_work := substr( r.log_text, n_start, 1000 );
		n_equal := instr( s_work, '=' );
		n_end := instr( s_work, ')' );

		s_user_name := substr( s_work, n_equal+1, n_end-n_equal-1 );

		--
		-- Find the name of the HOST.
		--
		n_start := instr( r.log_text, 'HOST' );
		s_work := substr( r.log_text, n_start, 1000 );
		n_equal := instr( s_work, '=' );
		n_end := instr( s_work, ')' );

		s_host_name := substr( s_work, n_equal+1, n_end-n_equal-1 );

		--
		-- Find the name of the HOST IP.
		--
		n_start := instr( r.log_text, 'HOST' );
		s_work := substr( r.log_text, n_start+5, 1000 );
		n_start := instr( s_work, 'HOST' );
		if n_start > 0 then
			s_work := substr( s_work, n_start, 1000 );
			n_equal := instr( s_work, '=' );
			n_end := instr( s_work, ')' );

			s_host_ip := substr( s_work, n_equal+1, n_end-n_equal-1 );
		
		else
			s_host_ip := null;
		end if;

		--
		-- Find the name of the PORT.
		--
		n_start := instr( r.log_text, 'PORT' );
		if n_start > 0 then
			s_work := substr( r.log_text, n_start, 1000 );
			n_equal := instr( s_work, '=' );
			n_end := instr( s_work, ')' );

			s_host_port := substr( s_work, n_equal+1, n_end-n_equal-1 );
		
		else
			s_host_port := null;
		end if;
		update	listener_log
		set	program_name = s_program_name,
			user_name = s_user_name,
			host_name = s_host_name,
			host_ip = s_host_ip,
			host_port = s_host_port,
			parsed = 'Y'
		where	id = r.id;
	end loop;
	commit;
end;
/

--begin 
--	dbms_stats.gather_schema_stats( '$2', cascade => true,
--		estimate_percent => dbms_stats.auto_sample_size );
--end; 
--/ 

exit;
EOF

