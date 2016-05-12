TIMING START Rates

TIMING START Base_rates

delete from r_cstm_tab.base_rate_hist;

----------------------------------------------------------------------------
--- Insert into base rate table new records load 
----------------------------------------------------------------------------
INSERT into r_cstm_tab.base_rate_hist (
	state, 
	groupline, 
	company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	userline, 
	base_rate	
	)
SELECT	a02_state, 
	a36_groupline, 
	a01_company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	b80_userline,
	base_rate
FROM	d_trn_tab.base_rates_merge r;

----------------------------------------------------------------------------
--- Set the "To Date" for new business rates in BASE_RATE_HIST table
----------------------------------------------------------------------------
UPDATE r_cstm_tab.base_rate_hist a
SET new_business_to_date = (
		SELECT 	nvl(min(new_business_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		FROM 	r_cstm_tab.base_rate_hist b
		WHERE 	a.state = state
		and 	a.company = company
		and 	a.groupline = groupline
		and 	a.userline = userline
		and 	a.new_business_fdate < b.new_business_fdate	
		)
/

----------------------------------------------------------------------------
--- Set the "To Date" for Renewal business rates in BASE_RATE_HIST table
----------------------------------------------------------------------------
UPDATE r_cstm_tab.base_rate_hist a
SET renewal_to_date = (
		SELECT 	nvl(min(renewal_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		FROM 	r_cstm_tab.base_rate_hist b
		WHERE 	a.state = state
		and 	a.company = company
		and 	a.groupline = groupline
		and 	a.userline = userline
		and 	a.renewal_fdate < b.renewal_fdate	
		)
/

----------------------------------------------------------------------------
--- Change the "To Date" of expired Base Rates to expiration date
----------------------------------------------------------------------------
declare
	cursor cur_nb_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			b80_userline as userline, 
			max(new_business_fdate) as new_business_fdate,
			new_business_xdate
		from	d_trn_tab.base_rates_merge
		where	new_business_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a01_company, a02_state, a36_groupline, b80_userline, new_business_xdate;
	--
	cursor cur_ren_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			b80_userline as userline, 
			max(renewal_fdate) as renewal_fdate,
			renewal_xdate
		from	d_trn_tab.base_rates_merge
		where	renewal_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a02_state, a36_groupline, a01_company, b80_userline, renewal_xdate;
begin
	for r in cur_nb_xdate loop
		update	r_cstm_tab.base_rate_hist
		set	new_business_to_date 	= r.new_business_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and 	userline 	= r.userline
		and	new_business_fdate = r.new_business_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;
	--
	for r in cur_ren_xdate loop
		update	r_cstm_tab.base_rate_hist
		set	renewal_to_date	= r.renewal_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and 	userline 	= r.userline
		and	renewal_fdate	= r.renewal_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;	
end;
/

COMMIT;
TIMING STOP


TIMING START Territory
delete from r_cstm_tab.territory_factor_hist;

----------------------------------------------------------------------------
--- Insert into territory factor table new records load 
----------------------------------------------------------------------------
INSERT into r_cstm_tab.territory_factor_hist (
	state, 
	groupline, 
	company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	territory, 
	territory_factor	
	)
SELECT	a02_state, 
	a36_groupline, 
	a01_company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	b82_territory,
	territory_factor
FROM	d_trn_tab.territory_factor_merge r;

----------------------------------------------------------------------------
--- Set the "To Date" for new business in TERRITORY_FACTOR_HIST table
----------------------------------------------------------------------------
UPDATE r_cstm_tab.territory_factor_hist a
SET new_business_to_date = (
		SELECT 	nvl(min(new_business_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		FROM 	r_cstm_tab.territory_factor_hist b
		WHERE 	a.state = state
		and 	a.company = company
		and 	a.groupline = groupline
		and 	a.territory = territory
		and 	a.new_business_fdate < b.new_business_fdate	
		)
/

----------------------------------------------------------------------------
--- Set the "To Date" for renewal business in TERRITORY_FACTOR_HIST table
----------------------------------------------------------------------------
UPDATE r_cstm_tab.territory_factor_hist a
SET renewal_to_date = (
		SELECT 	nvl(min(renewal_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		FROM 	r_cstm_tab.territory_factor_hist b
		WHERE 	a.state = state
		and 	a.company = company
		and 	a.groupline = groupline
		and 	a.territory = territory
		and 	a.renewal_fdate < b.renewal_fdate	
		)
/

----------------------------------------------------------------------------
--- Change the "To Date" of expired Territory Factors to expiration date
----------------------------------------------------------------------------
declare
	cursor cur_nb_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			b82_territory as territory, 
			max(new_business_fdate) as new_business_fdate,
			new_business_xdate
		from	d_trn_tab.territory_factor_merge
		where	new_business_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a01_company, a02_state, a36_groupline, b82_territory, new_business_xdate;
	--
	cursor cur_ren_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			b82_territory as territory, 
			max(renewal_fdate) as renewal_fdate,
			renewal_xdate
		from	d_trn_tab.territory_factor_merge
		where	renewal_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a02_state, a36_groupline, a01_company, b82_territory, renewal_xdate;
begin
	for r in cur_nb_xdate loop
		update	r_cstm_tab.territory_factor_hist
		set	new_business_to_date 	= r.new_business_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and 	territory 	= r.territory
		and	new_business_fdate = r.new_business_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;
	--
	for r in cur_ren_xdate loop
		update	r_cstm_tab.territory_factor_hist
		set	renewal_to_date	= r.renewal_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and 	territory 	= r.territory
		and	renewal_fdate	= r.renewal_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;	
end;
/

COMMIT;
TIMING STOP


TIMING START Specialty
delete from r_cstm_tab.specialty_factor_hist;

----------------------------------------------------------------------------
--- Insert into specialty factor table new records load  
----------------------------------------------------------------------------
INSERT into r_cstm_tab.specialty_factor_hist (
	state, 
	groupline, 
	company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	specialty,
	territory, 
	specialty_factor	
	)
SELECT	a02_state, 
	a36_groupline, 
	a01_company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	b83_class,
	b82_territory,
	specialty_factor
FROM	d_trn_tab.specialty_factor_merge r;

----------------------------------------------------------------------------
--- Set the "To Date" for new business in SPECIALTY_FACTOR_HIST table
----------------------------------------------------------------------------
create index tmpspecialty_factor_hist on r_cstm_tab.specialty_factor_hist(
  specialty, state, territory, groupline, company, new_business_fdate )
storage (initial 1m next 1m pctincrease 0 );

declare
	dtMinRateFDate date;
	--
	cursor cur_sfh is
		select state, company, groupline, specialty, territory, new_business_fdate, rowid as row_id
		from r_cstm_tab.specialty_factor_hist;
begin
	for r in cur_sfh loop
		SELECT 	nvl(min(new_business_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		INTO	dtMinRateFDate
		FROM 	r_cstm_tab.specialty_factor_hist
		WHERE 	state 		= r.state
		and 	company 	= r.company
		and 	groupline 	= r.groupline
		and	specialty 	= r.specialty
		and 	territory 	= r.territory
		and 	r.new_business_fdate < new_business_fdate;
		--
		UPDATE	r_cstm_tab.specialty_factor_hist a
		SET	new_business_to_date = dtMinRateFDate
		WHERE	rowid = r.row_id;
	end loop;
end;
/

drop index tmpspecialty_factor_hist;

----------------------------------------------------------------------------
--- Set the "To Date" for renewal in SPECIALTY_FACTOR_HIST table
----------------------------------------------------------------------------
create index tmpspecialty_factor_hist on r_cstm_tab.specialty_factor_hist(
  specialty, state, territory, groupline, company, renewal_fdate )
storage (initial 1m next 1m pctincrease 0 );

declare
	dtMinRateFDate date;
	--
	cursor cur_sfh is
		select state, company, groupline, specialty, territory, renewal_fdate, rowid as row_id
		from r_cstm_tab.specialty_factor_hist;
begin
	for r in cur_sfh loop
		SELECT 	nvl(min(renewal_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		INTO	dtMinRateFDate
		FROM 	r_cstm_tab.specialty_factor_hist
		WHERE 	state 		= r.state
		and 	company 	= r.company
		and 	groupline 	= r.groupline
		and	specialty 	= r.specialty
		and 	territory 	= r.territory
		and 	r.renewal_fdate < renewal_fdate;
		--
		UPDATE	r_cstm_tab.specialty_factor_hist a
		SET	renewal_to_date = dtMinRateFDate
		WHERE	rowid = r.row_id;
	end loop;
end;
/

drop index tmpspecialty_factor_hist;

----------------------------------------------------------------------------
--- Change the "To Date" of expired Specialty Factors to expiration date
----------------------------------------------------------------------------
declare
	cursor cur_nb_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			b83_class as specialty,
			b82_territory as territory, 
			max(new_business_fdate) as new_business_fdate,
			new_business_xdate
		from	d_trn_tab.specialty_factor_merge
		where	new_business_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a01_company, a02_state, a36_groupline, b83_class, b82_territory, new_business_xdate;
	--
	cursor cur_ren_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			b83_class as specialty,
			b82_territory as territory, 
			max(renewal_fdate) as renewal_fdate,
			renewal_xdate
		from	d_trn_tab.specialty_factor_merge
		where	renewal_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a02_state, a36_groupline, a01_company, b83_class, b82_territory, renewal_xdate;
begin
	for r in cur_nb_xdate loop
		update	r_cstm_tab.specialty_factor_hist
		set	new_business_to_date 	= r.new_business_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and	specialty	= r.specialty
		and 	territory 	= r.territory
		and	new_business_fdate = r.new_business_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;
	--
	for r in cur_ren_xdate loop
		update	r_cstm_tab.specialty_factor_hist
		set	renewal_to_date	= r.renewal_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and	specialty	= r.specialty
		and 	territory 	= r.territory
		and	renewal_fdate	= r.renewal_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;	
end;
/

COMMIT;
TIMING STOP


TIMING START Maturation
delete from r_cstm_tab.maturation_factor_hist;

----------------------------------------------------------------------------
--- Insert into maturation factor table new records load  
----------------------------------------------------------------------------
INSERT into r_cstm_tab.maturation_factor_hist (
	state, 
	groupline, 
	company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	maturation_year,
	maturation_factor	
	)
SELECT	a02_state, 
	a36_groupline, 
	a01_company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	n66_maturation_year,
	maturation_factor
FROM	d_trn_tab.maturation_factor_merge r;

----------------------------------------------------------------------------
--- Set the "To Date" for new business in MATURATION_FACTOR_HIST table
----------------------------------------------------------------------------
UPDATE r_cstm_tab.maturation_factor_hist a
SET new_business_to_date = (
		SELECT 	nvl(min(new_business_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		FROM 	r_cstm_tab.maturation_factor_hist b
		WHERE 	a.state = state
		and 	a.company = company
		and 	a.groupline = groupline
		and 	a.maturation_year = maturation_year
		and 	a.new_business_fdate < b.new_business_fdate	
		)
/

----------------------------------------------------------------------------
--- Set the "To Date" for renewal business in MATURATION_FACTOR_HIST table
----------------------------------------------------------------------------
UPDATE r_cstm_tab.maturation_factor_hist a
SET renewal_to_date = (
		SELECT 	nvl(min(renewal_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		FROM 	r_cstm_tab.maturation_factor_hist b
		WHERE 	a.state = state
		and 	a.company = company
		and 	a.groupline = groupline
		and 	a.maturation_year = maturation_year
		and 	a.renewal_fdate < b.renewal_fdate	
		)
/

----------------------------------------------------------------------------
--- Change the "To Date" of expired Maturation Factors to expiration date
----------------------------------------------------------------------------
declare
	cursor cur_nb_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			n66_maturation_year as maturation_year, 
			max(new_business_fdate) as new_business_fdate,
			new_business_xdate
		from	d_trn_tab.maturation_factor_merge
		where	new_business_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a01_company, a02_state, a36_groupline, n66_maturation_year, new_business_xdate;
	--
	cursor cur_ren_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			n66_maturation_year as maturation_year, 
			max(renewal_fdate) as renewal_fdate,
			renewal_xdate
		from	d_trn_tab.maturation_factor_merge
		where	renewal_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a02_state, a36_groupline, a01_company, n66_maturation_year, renewal_xdate;
begin
	for r in cur_nb_xdate loop
		update	r_cstm_tab.maturation_factor_hist
		set	new_business_to_date 	= r.new_business_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and 	maturation_year = r.maturation_year
		and	new_business_fdate = r.new_business_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;
	--
	for r in cur_ren_xdate loop
		update	r_cstm_tab.maturation_factor_hist
		set	renewal_to_date	= r.renewal_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and 	maturation_year = r.maturation_year
		and	renewal_fdate	= r.renewal_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;	
end;
/

COMMIT;
TIMING STOP


TIMING START ILF
delete from r_cstm_tab.increase_limit_factor_hist;

----------------------------------------------------------------------------
--- Insert into ILF table new records load  
----------------------------------------------------------------------------
INSERT into r_cstm_tab.increase_limit_factor_hist (
	state, 
	groupline, 
	company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	incident_limit,
	aggregate_limit,
	medical_surgical_code,
	increase_limit_factor	
	)
SELECT	a02_state, 
	a36_groupline, 
	a01_company, 
	new_business_fdate,
	renewal_fdate,
	entry_fdate,
	i27_incident_limit,
	i27_aggregate_limit,
	medical_surgical_code,
	increase_limit_factor	
FROM	d_trn_tab.increase_limit_factor_merge r;

----------------------------------------------------------------------------
--- Set the "To Date" for new business in INCREASE_LIMIT_FACTOR_HIST table 
----------------------------------------------------------------------------
UPDATE r_cstm_tab.increase_limit_factor_hist a
SET new_business_to_date = (
		SELECT 	nvl(min(new_business_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		FROM 	r_cstm_tab.increase_limit_factor_hist b
		WHERE 	a.state = state
		and 	a.company = company
		and 	a.groupline = groupline
		and 	a.incident_limit = incident_limit
		and 	a.aggregate_limit = aggregate_limit
		and 	a.medical_surgical_code = medical_surgical_code
		and 	a.new_business_fdate < b.new_business_fdate	
		)
/

----------------------------------------------------------------------------
--- Set the "To Date" for renewal business in INCREASE_LIMIT_FACTOR_HIST 
----------------------------------------------------------------------------
UPDATE r_cstm_tab.increase_limit_factor_hist a
SET renewal_to_date = (
		SELECT 	nvl(min(renewal_fdate), 
			to_date('31-DEC-9999', 'DD-MON-YYYY'))
		FROM 	r_cstm_tab.increase_limit_factor_hist b
		WHERE 	a.state = state
		and 	a.company = company
		and 	a.groupline = groupline
		and 	a.incident_limit = incident_limit
		and 	a.aggregate_limit = aggregate_limit
		and 	a.medical_surgical_code = medical_surgical_code
		and 	a.renewal_fdate < b.renewal_fdate	
		)
/

-----------------------------------------------------------------------------
--- Change the "To Date" of expired Increase Limit Factors to expiration date
-----------------------------------------------------------------------------
declare
	cursor cur_nb_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			i27_incident_limit as incident_limit,
			i27_aggregate_limit as aggregate_limit,
			medical_surgical_code,
			max(new_business_fdate) as new_business_fdate,
			new_business_xdate
		from	d_trn_tab.increase_limit_factor_merge
		where	new_business_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a01_company, a02_state, a36_groupline, i27_incident_limit, i27_aggregate_limit, 
			medical_surgical_code, new_business_xdate;
	--
	cursor cur_ren_xdate is
		select	a01_company as company, 
			a02_state as state, 
			a36_groupline as groupline, 
			i27_incident_limit as incident_limit,
			i27_aggregate_limit as aggregate_limit,
			medical_surgical_code,
			max(renewal_fdate) as renewal_fdate,
			renewal_xdate
		from	d_trn_tab.increase_limit_factor_merge
		where	renewal_xdate <> to_date('31-DEC-9999', 'DD-MON-YYYY')
		group by a02_state, a36_groupline, a01_company, i27_incident_limit, i27_aggregate_limit, 
			medical_surgical_code, renewal_xdate;
begin
	for r in cur_nb_xdate loop
		update	r_cstm_tab.increase_limit_factor_hist
		set	new_business_to_date 	= r.new_business_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and 	incident_limit 	= r.incident_limit
		and 	aggregate_limit = r.aggregate_limit
		and 	medical_surgical_code = r.medical_surgical_code
		and	new_business_fdate = r.new_business_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;
	--
	for r in cur_ren_xdate loop
		update	r_cstm_tab.increase_limit_factor_hist
		set	renewal_to_date	= r.renewal_xdate
		where 	company 	= r.company
		and	state 		= r.state
		and 	groupline 	= r.groupline
		and 	incident_limit 	= r.incident_limit
		and 	aggregate_limit = r.aggregate_limit
		and 	medical_surgical_code = r.medical_surgical_code
		and	renewal_fdate	= r.renewal_fdate;
		--
		dbms_output.put_line('Rows updated: ' || (SQL%ROWCOUNT));
	end loop;	
end;
/

COMMIT;
