CREATE OR REPLACE package body TAG.userdata_light_pkg as
	procedure begin_refresh;
	procedure end_refresh( ps_status varchar2, ps_status_note varchar2 );
	procedure refresh_userdata( ps_db_link_prefix_tdb varchar2 );
	procedure refresh_address( ps_db_link_prefix_tdb varchar2 );
	procedure refresh_user_auth( ps_db_link_prefix_tdb varchar2 );
	procedure refresh_user_mail( ps_db_link_prefix_tdb varchar2 );
	procedure refresh_user_bouncelist( ps_db_link_prefix_pdb varchar2 );
	procedure refresh_userdata_extended( ps_db_link_prefix_tdb varchar2 );
	procedure build_userdata_light_table;

	procedure refresh_userdata_light( ps_db_link_prefix_tdb varchar2, ps_db_link_prefix_pdb varchar2 ) is
	begin
		begin_refresh;
		dbms_scheduler.create_job( job_name => 'USERDATA_LIGHT_PART1',
			job_type => 'PLSQL_BLOCK',
			job_action => 'begin userdata_light_pkg.refresh_userdata_light_part1( ''' || ps_db_link_prefix_tdb || ''' ); end;',
			comments => 'Populating USERDATA_MASTER from 64 shards',
			enabled => true,
			auto_drop => true );

		dbms_scheduler.create_job( job_name => 'USERDATA_LIGHT_PART2',
			job_type => 'PLSQL_BLOCK',
			job_action => 'begin userdata_light_pkg.refresh_userdata_light_part2( ''' || ps_db_link_prefix_tdb || ''', ''' || ps_db_link_prefix_pdb || ''' ); end;',
			comments => 'Populating USERDATA_*_MASTER (4 tables) from 64 shards',
			enabled => true,
			auto_drop => true );

		dbms_scheduler.create_job( job_name => 'USERDATA_LIGHT_PART3',
			job_type => 'PLSQL_BLOCK',
			job_action => 'begin userdata_light_pkg.refresh_userdata_light_part3( ''' || ps_db_link_prefix_tdb || ''' ); end;',
			comments => 'Building the USERDATA_LIGHT table',
			enabled => true,
			auto_drop => true );
	end refresh_userdata_light;

	procedure begin_refresh is
		n_control_id			integer;
		n_control_id_prior		integer;
		n_userdata_light_rows_prior	integer;
	begin
		begin
			select	control_id
			into	n_control_id
			from	userdata_light_control;
		exception
			when no_data_found then
				n_control_id := 0;
				insert into userdata_light_control( control_id ) values( n_control_id );
		end;

		update	userdata_light_control
		set	control_id = control_id + 1,
			current_state = 'RUNNING',
			status = 'GOOD',
			status_note = 'USERDATA_LIGHT refresh started at ' || to_char( sysdate, 'DD-MON-YYYY HH:MI AM' )
		returning control_id into n_control_id;

		begin
			select	max( control_id )
			into	n_control_id_prior
			from	userdata_light_history
			where	control_id < n_control_id;

			select	userdata_light_rows_current
			into	n_userdata_light_rows_prior
			from	userdata_light_history
			where	control_id = n_control_id_prior;
		exception
			when no_data_found then
				n_userdata_light_rows_prior := 0;
		end;

		insert into userdata_light_history(
			control_id, begin_date, userdata_light_rows_prior )
		values(
			n_control_id, sysdate, n_userdata_light_rows_prior );

		commit;
	end begin_refresh;

	procedure end_refresh( ps_status varchar2, ps_status_note varchar2 ) is
		n_control_id			integer;
		n_userdata_light_rows_current	integer := 0;
	begin
		update	userdata_light_control
		set	current_state = 'COMPLETED',
			status = ps_status,
			status_note = ps_status_note
		returning control_id into n_control_id;

		if ps_status = 'SUCCESS' then
			select	count(*)
			into	n_userdata_light_rows_current
			from	userdata_light;
		end if;

		update	userdata_light_history
		set	end_date = sysdate,
			userdata_light_rows_current = n_userdata_light_rows_current
		where	control_id = n_control_id;

		commit;
	end end_refresh;

	procedure refresh_userdata_light_part1( ps_db_link_prefix_tdb varchar2 ) is
	begin
		update	userdata_light_history
		set	part_1_begin_date = sysdate
		where	control_id = ( select control_id from userdata_light_control );

		commit;

		refresh_userdata( ps_db_link_prefix_tdb );

		update	userdata_light_history
		set	part_1_end_date = sysdate
		where	control_id = ( select control_id from userdata_light_control );

		commit;
	end refresh_userdata_light_part1;

	procedure refresh_userdata_light_part2( ps_db_link_prefix_tdb varchar2, ps_db_link_prefix_pdb varchar2 ) is
	begin
		update	userdata_light_history
		set	part_2_begin_date = sysdate
		where	control_id = ( select control_id from userdata_light_control );

		commit;

		refresh_address( ps_db_link_prefix_tdb );
		refresh_user_auth( ps_db_link_prefix_tdb );
		refresh_user_bouncelist( ps_db_link_prefix_pdb );
		refresh_user_mail( ps_db_link_prefix_tdb );
		refresh_userdata_extended( ps_db_link_prefix_tdb );

		update	userdata_light_history
		set	part_2_end_date = sysdate
		where	control_id = ( select control_id from userdata_light_control );

		commit;
	end refresh_userdata_light_part2;

	procedure refresh_userdata_light_part3( ps_db_link_prefix_tdb varchar2 ) is
		n_job_count	integer;
	begin
		--
		-- At this point all jobs have been started.
		-- Now we will wait until the first two jobs (refresh_userdata_light_part1 and refresh_userdata_light_part2)
		-- are complete and then we will proceed to allow refresh_userdata_light_part3 to execute.
		--
		while true loop
			-- NOTE: user_lock.sleep parameter is in centi-seconds (100th of a second).
			--       value of 100 = 1 second
			--       value of 1500 = 15 seconds
			--       value of 6000 = 60 seconds
			user_lock.sleep( 6000 );

			select	count(*)
			into	n_job_count
			from	all_scheduler_running_jobs
			where	job_name in( 'USERDATA_LIGHT_PART1', 'USERDATA_LIGHT_PART2' );

			if n_job_count = 0 then
				exit;
			end if;
		end loop;

		update	userdata_light_history
		set	part_3_begin_date = sysdate
		where	control_id = ( select control_id from userdata_light_control );

		commit;

		-- The first two parts are complete. Now build the userdata_light table.
		build_userdata_light_table;

		update	userdata_light_history
		set	part_3_end_date = sysdate
		where	control_id = ( select control_id from userdata_light_control );

		commit;

		end_refresh( 'SUCCESS', 'USERDATA_LIGHT refresh completed successfully.' );
	end refresh_userdata_light_part3;


	procedure refresh_userdata( ps_db_link_prefix_tdb varchar2 ) is
		n_db		integer;
		s_db		varchar2(10);		-- looks something like PDB01, PDB02, TDB00, etc.
		s_shard		varchar2(2);		-- looks something like '0', '6', '13', '56', etc.
		s_sql		varchar2(1000);
	begin
		execute immediate 'truncate table userdata_master';

		for d in 0..63
		loop
			n_db := d;

			s_db := ps_db_link_prefix_tdb || lpad( d, 2, '0' );
			s_shard := to_char( d );

                        s_sql := '
				insert into userdata_master(
					user_id, fictitious_user_id, cancel_reason_code,
					gender, birthdate, locale,
					last_login_date, apps_optout_settings_1, reg_source,
					ethnicity, religion, sexual_preference,
					type, hi5_finished_wizard_date, primary_photo_id,
					photo_url, dating, friends,
					serrelationship, networking, relationship,
					inferred_ethnicity, timezone_int_id, hide_online_status,
					search_prefs )
				select	user_id, fictitious_user_id, cancel_reason_code,
					gender, birthdate, locale,
					last_login_date, apps_optout_settings_1, reg_source,
					ethnicity, religion, sexual_preference,
					type, hi5_finished_wizard_date, primary_photo_id,
					photo_url, dating, friends,
					serrelationship, networking, relationship,
					inferred_ethnicity, timezone_int_id, hide_online_status,
					search_prefs
				from	userdata_view_p' || s_shard || '@' || s_db;

			--dbms_output.put_line( s_sql );
			execute immediate s_sql;

			begin
				commit;
				s_sql := 'alter session close database link ' || s_db;
				execute immediate s_sql;
			exception
				when others then
					null;
			end;
		end loop;
	end refresh_userdata;

	procedure refresh_address( ps_db_link_prefix_tdb varchar2 ) is
		n_db		integer;
		s_db		varchar2(10);		-- looks something like PDB01, PDB02, TDB00, etc.
		s_shard		varchar2(2);		-- looks something like '0', '6', '13', '56', etc.
		s_sql		varchar2(1000);
	begin
		execute immediate 'truncate table address_master';

		for d in 0..63
		loop
			n_db := d;

			s_db := ps_db_link_prefix_tdb || lpad( d, 2, '0' );
			s_shard := to_char( d );

                        s_sql := '
				insert into address_master(
					user_id, cc_iso, state,
					zipcode, zipcode_ext, latitude,
					longitude )
				select	user_id, substr( nvl( intl_cc_iso, ''US'' ), 1, 2 ) intl_cc_iso, substr( nvl( intl_state, ''CA'' ), 1, 2 ) intl_state,
					nvl( lpad( intl_zipcode, 5, 0 ), 0 ) intl_zipcode, nvl( zipcode_ext, 0 ) zipcode_ext, latitude,
					longitude
				from address_p' || s_shard || '@' || s_db;

			dbms_output.put_line( s_sql );
			execute immediate s_sql;

			begin
				commit;
				s_sql := 'alter session close database link ' || s_db;
				execute immediate s_sql;
			exception
				when others then
					null;
			end;
		end loop;
	end refresh_address;

	procedure refresh_user_auth( ps_db_link_prefix_tdb varchar2 ) is
		n_db		integer;
		s_db		varchar2(10);		-- looks something like PDB01, PDB02, TDB00, etc.
		s_shard		varchar2(2);		-- looks something like '0', '6', '13', '56', etc.
		s_sql		varchar2(1000);
	begin
		execute immediate 'truncate table user_auth_master';

		for d in 0..63
		loop
			n_db := d;

			s_db := ps_db_link_prefix_tdb || lpad( d, 2, '0' );
			s_shard := to_char( d );

                        s_sql := '
				insert into user_auth_master(
					user_id, primary_email_id, date_registered,
					date_cancelled, date_validated, date_boxed,
					boxed_reason, date_spammer_added, date_spammer_removed )
				select	user_id, primary_email_id, date_registered,
					date_cancelled, date_validated, date_boxed,
					boxed_reason, date_spammer_added, date_spammer_removed
				from user_auth_p' || s_shard || '@' || s_db;

			--dbms_output.put_line( s_sql );
			execute immediate s_sql;

			begin
				commit;
				s_sql := 'alter session close database link ' || s_db;
				execute immediate s_sql;
			exception
				when others then
					null;
			end;
		end loop;
	end refresh_user_auth;

	procedure refresh_user_mail( ps_db_link_prefix_tdb varchar2 ) is
		n_db		integer;
		s_db		varchar2(10);		-- looks something like PDB01, PDB02, TDB00, etc.
		s_shard		varchar2(2);		-- looks something like '0', '6', '13', '56', etc.
		s_sql		varchar2(1000);
	begin
		execute immediate 'truncate table user_email_master';

		for d in 0..63
		loop
			n_db := d;

			s_db := ps_db_link_prefix_tdb || lpad( d, 2, '0' );
			s_shard := to_char( d );

                        s_sql := '
				insert into user_email_master(
					user_id, email_address_id, email, email_blocked )
				select	user_id, email_address_id, replace( replace( replace( email, chr( 10 ) ), chr( 13 ) ), '','', ''.'' ),
					case when bl.email_address is null then ''N'' else ''Y'' end email_blocked 
				from	user_email_address_p' || s_shard || '@' || s_db || ' uea
					left join blocklist_p' || s_shard || '@' || s_db || ' bl
					on uea.email = bl.email_address';

			--dbms_output.put_line( s_sql );
			execute immediate s_sql;

			begin
				commit;
				s_sql := 'alter session close database link ' || s_db;
				execute immediate s_sql;
			exception
				when others then
					null;
			end;
		end loop;

		update	user_email_master uem
		set	email_blocked = 'Y'
		where	email in (
				select email from user_bouncelist_master );

		commit;
	end refresh_user_mail;

	procedure refresh_user_bouncelist( ps_db_link_prefix_pdb varchar2 ) is
		n_db		integer;
		n_shard		integer;
		s_db		varchar2(10);		-- looks something like PDB01, PDB02, TDB00, etc.
		s_shard		varchar2(2);		-- looks something like '0', '6', '13', '56', etc.
		s_sql		varchar2(500);

		type t_shard is table of integer index by pls_integer;
		type r_db is record( shard t_shard );
		type t_db is table of r_db index by pls_integer;
		db t_db;
	begin
		-- each shard has 8 shards (0-7, 16-23, 32-39, 48-55, 8-15, 24-31, 40-47, 56-63)
		db(1).shard(1) := 0; db(1).shard(2) := 1; db(1).shard(3) := 2; db(1).shard(4) := 3; db(1).shard(5) := 4; db(1).shard(6) := 5; db(1).shard(7) := 6; db(1).shard(8) := 7;
		db(2).shard(1) := 16; db(2).shard(2) := 17; db(2).shard(3) := 18; db(2).shard(4) := 19; db(2).shard(5) := 20; db(2).shard(6) := 21; db(2).shard(7) := 22; db(2).shard(8) := 23;
		db(3).shard(1) := 32; db(3).shard(2) := 33; db(3).shard(3) := 34; db(3).shard(4) := 35; db(3).shard(5) := 36; db(3).shard(6) := 37; db(3).shard(7) := 38; db(3).shard(8) := 39;
		db(4).shard(1) := 48; db(4).shard(2) := 49; db(4).shard(3) := 50; db(4).shard(4) := 51; db(4).shard(5) := 52; db(4).shard(6) := 53; db(4).shard(7) := 54; db(4).shard(8) := 55;

		db(5).shard(1) := 8; db(5).shard(2) := 9; db(5).shard(3) := 10; db(5).shard(4) := 11; db(5).shard(5) := 12; db(5).shard(6) := 13; db(5).shard(7) := 14; db(5).shard(8) := 15;
		db(6).shard(1) := 24; db(6).shard(2) := 25; db(6).shard(3) := 26; db(6).shard(4) := 27; db(6).shard(5) := 28; db(6).shard(6) := 29; db(6).shard(7) := 30; db(6).shard(8) := 31;
		db(7).shard(1) := 40; db(7).shard(2) := 41; db(7).shard(3) := 42; db(7).shard(4) := 43; db(7).shard(5) := 44; db(7).shard(6) := 45; db(7).shard(7) := 46; db(7).shard(8) := 47;
		db(8).shard(1) := 56; db(8).shard(2) := 57; db(8).shard(3) := 58; db(8).shard(4) := 59; db(8).shard(5) := 60; db(8).shard(6) := 61; db(8).shard(7) := 62; db(8).shard(8) := 63;

		execute immediate 'truncate table user_bouncelist_master';

		for d in 1..8
		loop
			for s in 1..8
			loop
				n_db := d;
				n_shard := db(d).shard(s);

				s_db := ps_db_link_prefix_pdb || lpad( d, 2, '0' );
				s_shard := to_char( db(d).shard(s) );

	                        s_sql := '
					insert into user_bouncelist_master(
						email )
					select	email 
					from	bouncelist_p' || s_shard || '@' || s_db;

				--dbms_output.put_line( s_sql );
				execute immediate s_sql;

				begin
					commit;
					s_sql := 'alter session close database link ' || s_db;
					execute immediate s_sql;
				exception
					when others then
						null;
				end;
			end loop;
		end loop;	end refresh_user_bouncelist;

	procedure refresh_userdata_extended( ps_db_link_prefix_tdb varchar2 ) is
		n_db		integer;
		s_db		varchar2(10);		-- looks something like PDB01, PDB02, TDB00, etc.
		s_shard		varchar2(2);		-- looks something like '0', '6', '13', '56', etc.
		s_sql		varchar2(1000);
	begin
		execute immediate 'truncate table userdata_extended_master';

		for d in 0..63
		loop
			n_db := d;

			s_db := ps_db_link_prefix_tdb || lpad( d, 2, '0' );
			s_shard := to_char( d );

                        s_sql := '
				insert into userdata_extended_master(
					user_id, ip_address, referrer_user_id,
					pets_search_prefs )
				select	user_id, ip_address, referrer_user_id,
					replace( pets_search_prefs, '','', ''|'' )
				from	userdata_extended_p' || s_shard || '@' || s_db;

			--dbms_output.put_line( s_sql );
			execute immediate s_sql;

			begin
				commit;
				s_sql := 'alter session close database link ' || s_db;
				execute immediate s_sql;
			exception
				when others then
					null;
			end;
		end loop;
	end refresh_userdata_extended;

	procedure build_userdata_light_table is
		s_sql			varchar2(2000);
		s_tablespace_name	varchar2(30);
	begin
		select	tablespace_name
		into	s_tablespace_name
		from	user_tablespaces
		where	tablespace_name like 'SPIN%'
		or	tablespace_name like 'DATA%'
		order by tablespace_name desc
		fetch first 1 rows only;

		begin
			s_sql := 'drop table userdata_light_tmp';
			execute immediate s_sql;
		exception
			when others then
				null;
		end;

		s_sql := '
			create table userdata_light_tmp
			tablespace ' || s_tablespace_name || '
			as
			select  /*+ parallel(4) */ a.user_id, a.fictitious_user_id, a.cancel_reason_code, a.gender, a.birthdate,
				a.locale, a.apps_optout_settings_1, date_registered, b.date_cancelled, b.date_validated,
				c.email, c.email_blocked, trim( d.cc_iso ) cc_iso,
				lower( substr( dbms_obfuscation_toolkit.md5( input => utl_raw.cast_to_raw( nvl( c.email, ''_'' ) ) ), 1, 15 ) ) potential_fict_user_id,
				a.last_login_date, e.ip_address,
				trim( d.state ) state, d.zipcode, d.zipcode_ext, b.date_boxed, b.boxed_reason,
				a.reg_source, a.ethnicity, a.religion, a.sexual_preference, a.type,
				a.hi5_finished_wizard_date,  a.primary_photo_id,  a.photo_url,  a.dating,  a.friends,
				a.serrelationship,  a.networking,  a.relationship,  a.inferred_ethnicity, d.latitude,
				d.longitude, a.timezone_int_id, a.hide_online_status, a.search_prefs, e.referrer_user_id,
				e.pets_search_prefs, b.date_spammer_added, b.date_spammer_removed
			from    userdata_master a
				left join user_auth_master b
					on a.user_id=b.user_id
				left join user_email_master c
					on a.user_id=c.user_id
					and b.primary_email_id = c.email_address_id
				left join ( select user_id, cc_iso, state, zipcode, zipcode_ext, latitude, longitude, row_number() over (partition by user_id order by user_id) prime from address_master ) d
					on a.user_id=d.user_id
					and d.prime = 1
				left join userdata_extended_master e
					on a.user_id=e.user_id';
		execute immediate s_sql;

		begin
			s_sql := 'alter table userdata_light_tmp noparallel';
			execute immediate s_sql;
		exception
			when others then
				null;
		end;

		begin
			s_sql := '
				create index userdata_light_tmp_ix1 on userdata_light_tmp( last_login_date )
				tablespace ' || s_tablespace_name || '
				parallel 4';
			execute immediate s_sql;
		exception
			when others then
				null;
		end;

		begin
			s_sql := 'alter index userdata_light_tmp_ix1 noparallel';
			execute immediate s_sql;
		exception
			when others then
				null;
		end;

		begin
			s_sql := 'drop table userdata_light_save purge';
			execute immediate s_sql;
		exception
			when others then
				null;
		end;

		begin
			s_sql := 'rename userdata_light to userdata_light_save';
			execute immediate s_sql;
		exception
			when others then
				null;
		end;

		begin
			s_sql := 'alter index userdata_light_ix1 rename to userdata_light_save_ix1';
			execute immediate s_sql;
		exception
			when others then
				null;
		end;

		begin
			s_sql := 'rename userdata_light_tmp to userdata_light';
			execute immediate s_sql;
		exception
			when others then
				null;
		end;

		begin
			s_sql := 'alter index userdata_light_tmp_ix1 rename to userdata_light_ix1';
			execute immediate s_sql;
		exception
			when others then
				null;
		end;

	end build_userdata_light_table;
end userdata_light_pkg;
/