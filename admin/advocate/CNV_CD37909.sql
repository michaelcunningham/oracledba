PROMPT BEGIN - $Workfile: CNV_CD37909.sql$ ($Revision: 6$)

/****** Object:  View CLIENT_NAMES    Script Date: 11/28/00 11:48:50 AM ******/

CREATE OR REPLACE VIEW client_names
(
	client_number,
	client_type,
	client_name,
	company_contact
)
AS
	SELECT client_number,
			 client_type,
			 substr (
				 CASE client_type
					 WHEN 'C'
					 THEN
						 RTRIM (lname1)
					 ELSE
						 LTRIM (
							 CASE 										/* Client Type = P */
								 /*  Two people same last name */
								 WHEN 	(lname1 = lname2)
										OR (lname2 IS NOT NULL AND lname1 IS NULL)
								 THEN
										RTRIM (nvl (prefix1, ' '))
									 || RTRIM (' ' || nvl (fname1, ' '))
									 || CASE nvl (length (RTRIM (init1)), 0)
											WHEN 1 THEN RTRIM (' ' || init1) || '. '
											WHEN 0 THEN RTRIM (' ')
											ELSE RTRIM (' ' || init1)
										END
									 || RTRIM (' ' || nvl (suffix1, ' '))
									 || ' &'
									 || RTRIM (' ' || nvl (prefix2, ' '))
									 || RTRIM (' ' || nvl (fname2, ' '))
									 || CASE nvl (length (RTRIM (init2)), 0)
											WHEN 1 THEN RTRIM (' ' || init2) || '.'
											WHEN 0 THEN RTRIM (' ')
											ELSE RTRIM (' ' || init2)
										END
									 || RTRIM (' ' || nvl (lname2, ' '))
									 || RTRIM (' ' || nvl (suffix2, ' ')) /*  Use two full names */
								 WHEN 	RTRIM (fname2) IS NOT NULL
										OR RTRIM (init2) IS NOT NULL
										OR RTRIM (lname2) IS NOT NULL
								 THEN
										RTRIM (nvl (prefix1, ' '))
									 || RTRIM (' ' || nvl (fname1, ' '))
									 || CASE nvl (length (RTRIM (init1)), 0)
											WHEN 1 THEN RTRIM (' ' || init1) || '.'
											WHEN 0 THEN RTRIM (' ')
											ELSE RTRIM (' ' || init1)
										END
									 || RTRIM (' ' || nvl (lname1, ' '))
									 || RTRIM (' ' || nvl (suffix1, ' '))
									 || ' &'
									 || RTRIM (' ' || nvl (prefix2, ' '))
									 || RTRIM (' ' || nvl (fname2, ' '))
									 || CASE nvl (length (RTRIM (init2)), 0)
											WHEN 1 THEN RTRIM (' ' || init2) || '.'
											WHEN 0 THEN RTRIM (' ')
											ELSE RTRIM (' ' || init2)
										END
									 || RTRIM (' ' || nvl (lname2, ' '))
									 || RTRIM (' ' || nvl (suffix2, ' '))
								 ELSE 										 /* Single Name */
										RTRIM (nvl (prefix1, ' '))
									 || RTRIM (' ' || nvl (fname1, ' '))
									 || CASE nvl (length (RTRIM (init1)), 0)
											WHEN 1 THEN RTRIM (' ' || init1) || '.'
											WHEN 0 THEN RTRIM (' ')
											ELSE RTRIM (' ' || init1)
										END
									 || RTRIM (' ' || nvl (lname1, ' '))
									 || RTRIM (' ' || nvl (suffix1, ' '))
							 END											/* Client Type = P */
								 )
				 END,
				 1,
				 254															/*  client type */
					 ),															/* substring */
			 substr (
				 CASE client_type
					 WHEN 'C'
					 THEN
						 LTRIM (
								RTRIM (nvl (prefix2, ' '))
							 || RTRIM (' ' || nvl (fname2, ' '))
							 || RTRIM (' ' || nvl (init2, ' '))
							 || RTRIM (' ' || nvl (lname2, ' '))
							 || RTRIM (' ' || nvl (suffix2, ' ')))
					 ELSE
						 NULL 										  /* Client Type =  P */
				 END,
				 1,
				 254) 													/* Company Contact */
	  FROM client
/

CREATE OR REPLACE VIEW blv_totals
(
	master_account_id,
	bill_date,
	gross,
	net,
	pay_gross,
	pay_net,
	in_dispute_count,
	comment_counter
)
AS
	SELECT	a.master_account_id,
				i.item_bill_date,
				SUM (i.gross_amount),
				SUM (i.net_amount),
				SUM (p.pay_gross),
				SUM (p.pay_net),
				SUM (i.in_dispute),
				SUM (i.comment_count)
		 FROM bl_acct_activity a,
					bl_acct_item i
				LEFT OUTER JOIN
					bl_bipay p
				ON i.item_id = p.the_key
		WHERE a.activity_id = i.activity_id AND a.activity_group != 'R'
	GROUP BY a.master_account_id, i.item_bill_date
/

/****** Object:  View BLV_BIDPSALL    Script Date: 11/28/00 11:48:49 AM ******/

CREATE OR REPLACE VIEW blv_bidpsall
(
	master_account_id,
	policy_number,
	portfolio_set,
	client_name,
	policy_eff_date,
	gross,
	net,
	pay_gross,
	pay_net,
	in_dispute_count,
	comment_counter,
	status_count
)
AS
	SELECT	a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date,
				SUM (i.gross_amount),
				SUM (i.net_amount),
				SUM (p.pay_gross),
				SUM (p.pay_net),
				SUM (i.in_dispute),
				SUM (i.comment_count),
				SUM (i.open_flag)
		 FROM bl_acct_activity a,
					bl_acct_item i
				LEFT OUTER JOIN
					bl_bipay p
				ON i.item_id = p.the_key
		WHERE a.activity_id = i.activity_id AND a.activity_group != 'R'
	GROUP BY a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date
/
/
/

/****** Object:  View BLV_BIDPS    Script Date: 11/28/00 11:48:49 AM ******/

CREATE OR REPLACE VIEW blv_bidps
(
	master_account_id,
	policy_number,
	portfolio_set,
	client_name,
	policy_eff_date,
	item_bill_date,
	gross,
	net,
	pay_gross,
	pay_net,
	in_dispute_count,
	comment_counter,
	status_count
)
AS
	SELECT	a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date,
				i.item_bill_date,
				SUM (i.gross_amount),
				SUM (i.net_amount),
				SUM (p.pay_gross),
				SUM (p.pay_net),
				SUM (i.in_dispute),
				SUM (i.comment_count),
				SUM (i.open_flag)
		 FROM bl_acct_activity a,
					bl_acct_item i
				LEFT OUTER JOIN
					bl_bipay p
				ON i.item_id = p.the_key
		WHERE a.activity_id = i.activity_id AND a.activity_group != 'R'
	GROUP BY a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date,
				i.item_bill_date
/
/
/

CREATE OR REPLACE VIEW solo_pa
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	name,
	cov_solo_pa,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 short_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00q' AND termination_date IS NULL
/
/
/

/****** Object:  View RENEWAL_POLICIES    Script Date: 11/28/00 11:48:52 AM ******/

CREATE OR REPLACE VIEW renewal_policies
(
	policy_date_time,
	renewal_code,
	policy_number,
	pol_eff_date,
	pol_exp_date,
	installment_date,
	agency_id,
	client_number,
	annual_premium,
	pol_type,
	company_name,
	status_1,
	user_id,
	portfolio_set
)
AS
	SELECT p.policy_date_time,
			 p.renewal_code,
			 p.policy_number,
			 p.pol_eff_date,
			 p.pol_exp_date,
			 p.installment_date,
			 p.agency_id,
			 p.client_number,
			 p.annual_premium,
			 p.pol_type,
			 p.company_name,
			 r.status_1,
			 r.user_id,
			 r.portfolio_set
	  FROM register r, policy p
	 WHERE	  p.policy_number = r.policy_number
			 AND p.policy_date_time = r.policy_date_time
			 AND p.renewal_code < '3'
			 AND r.status_1 != '1'
			 AND r.status_1 != '6'
			 AND r.status_1 != '7'
			 AND r.status_1 != 'A'
			 AND r.status_2 = '0'
			 AND r.status_3 = 'A'
			 AND r.reason_suspended = '000'
/
/
/

/****** Object:  View REGISTER_CUR    Script Date: 11/28/00 11:48:52 AM ******/

CREATE OR REPLACE VIEW register_cur
(
	policy_number,
	status_1,
	audit_status,
	status_date_1,
	policy_date_time,
	check_out,
	user_id,
	status_2,
	portfolio_set
)
AS
	SELECT policy_number,
			 status_1,
			 audit_status,
			 status_date_1,
			 policy_date_time,
			 check_out,
			 user_id,
			 status_2,
			 portfolio_set
	  FROM register
	 WHERE status_3 = 'A'
/

CREATE OR REPLACE VIEW policy_term_prem
AS
	SELECT DISTINCT
			 pd.policy_number,
			 pd.policy_date_time,
			 pd.premium_lob,
			 pd.sequence_number,
			 pd.term_seq,
				pd.annualized_premium
			 * (p.pol_exp_date - p.pol_eff_date)
			 / (ADD_MONTHS (pol_eff_date, 12) - pol_eff_date)
				 AS pol_term_prem,
			 ROUND (
					pd.annualized_premium
				 * (p.pol_exp_date - p.pol_eff_date)
				 / (ADD_MONTHS (pol_eff_date, 12) - pol_eff_date),
				 0)
				 AS pol_term_prem_rnd
	  FROM premium_detail pd, policy p, register r
	 WHERE	  pd.policy_number = p.policy_number
			 AND pd.policy_date_time = p.policy_date_time
			 AND pd.policy_number = r.policy_number
			 AND pd.policy_date_time = r.policy_date_time
			 AND r.status_1 IN ('2', '4', '5', '6', '8')
			 AND p.plan_term_days IS NOT NULL
			 AND p.plan_term_days != (p.pol_exp_date - p.pol_eff_date)
/


CREATE OR REPLACE VIEW sv_portfolio_set_last
(
	policy_number,
	portfolio_set,
	cur_policy_date_time
)
AS
	SELECT	p.policy_number, r.portfolio_set, MAX (p.policy_date_time)
		 FROM 	policy p
				INNER JOIN
					register r
				ON 	 r.policy_number = p.policy_number
					AND r.policy_date_time = p.policy_date_time
		WHERE (r.audit_status IS NULL AND r.status_3 = 'A')
	GROUP BY p.policy_number, r.portfolio_set
/

--we're commenting out fields that have all nulls and are being dropped in the export of data from sqlserver to oracle
CREATE OR REPLACE VIEW hgl_exposure
(
    address_number,
--    beach_district,
    prior_liab_lmt,
    amb_pol_lmt,
    adv_lmt,
    gen_agg_lmt,
    prod_agg_lmt,
    dmg_lmt,
    med_lmt,
    occ_lmt,
    rating_county,
    client_number,
--    county_code,
    group_disc,
    gl_prem,
    exper_disc,
    discount_2,
    claims_made_debit,
    grievance,
    review,
    new_practice,
    part_time,
    alteration,
    no_coverage,
    fda_approved,
    expiring_coverage,
    imp_phys_prog,
    no_risk_magmt,
    other_debit,
    other_credit,
    loss_frequency,
    longevity_credit,
    cme_risk_magmt,
    vic_liab_debit,
    misc_debit_1,
    misc_debit_2,
    misc_debit_3,
    misc_debit_4,
    misc_debit_5,
    misc_debit_6,
    misc_debit_7,
    misc_debit_8,
    misc_debit_9,
    misc_debit_10,
--    division,
    effective_date,
--    fire_district_code,
    identifier,
    acute_bed,
    psych_bed,
    rehab_bed,
    ext_bed,
    icu_bed,
    er_visit,
    ther_visit,
    visit,
    out_visit,
    in_proc,
    out_proc,
    births,
    vic,
    para,
    med_dir,
    sq_ft,
    exp_prem,
--    liab_rate_group,
    plan_code,
    policy_date_time,
    policy_number,
    rating_state,
    reference_number,
    sequence_number,
--    state_code,
--    sub_county_code,
    termination_date,
    territory_code_01,
    /*territory_code_02,
    territory_code_03,
    territory_code_04,
    territory_code_05,
    territory_code_06,
    territory_code_07,
    territory_code_08,
    territory_code_09,*/
--    town_code,
    retro_date,
    standard_10,
    long_disc,
    hpl_prem,
    bassinets,
    clinic_visits,
    sub_acute_beds,
    skill_nurse_beds,
    interm_care_beds,
    asst_living_beds,
    pers_care_beds,
--    indep_living_beds,
    exp_inc_date,
    policy_type
)
AS
    SELECT address_number,
             --beach_district,
             char_01_01,
             char_01_02,
             char_01_03,
             char_01_04,
             char_01_05,
             char_01_06,
             char_01_07,
             char_01_08,
             char_03_01,
             client_number,
             --county_code,
             decimal_14_2_04,
             decimal_14_2_02,
             decimal_14_2_05,
             decimal_14_2_08,
             decimal_14_2_112,
             decimal_14_2_114,
             decimal_14_2_117,
             decimal_14_2_118,
             decimal_14_2_119,
             decimal_14_2_124,
             decimal_14_2_125,
             decimal_14_2_126,
             decimal_14_2_127,
             decimal_14_2_128,
             decimal_14_2_130,
             decimal_14_2_131,
             decimal_14_2_132,
             decimal_14_2_133,
             decimal_14_2_135,
             decimal_14_2_136,
             decimal_14_2_138,
             decimal_14_2_139,
             decimal_14_2_140,
             decimal_14_2_141,
             decimal_14_2_142,
             decimal_14_2_143,
             decimal_14_2_144,
             decimal_14_2_145,
             decimal_14_2_146,
             decimal_14_2_147,
             decimal_14_2_148,
             --division,
             effective_date,
             --fire_district_code,
             identifier,
             integer_01,
             integer_02,
             integer_03,
             integer_04,
             integer_05,
             integer_06,
             integer_07,
             integer_08,
             integer_09,
             integer_10,
             integer_100,
             integer_11,
             integer_12,
             integer_13,
             integer_14,
             integer_15,
             integer_20,
             --liab_rate_group,
             plan_code,
             policy_date_time,
             policy_number,
             rating_state,
             reference_number,
             sequence_number,
             --state_code,
             --sub_county_code,
             termination_date,
             territory_code_01,
             /*territory_code_02,
             territory_code_03,
             territory_code_04,
             territory_code_05,
             territory_code_06,
             territory_code_07,
             territory_code_08,
             territory_code_09,*/
             --town_code,
             date_01,
             decimal_14_2_03,
             decimal_14_2_04,
             decimal_14_2_06,
             integer_21,
             integer_22,
             integer_23,
             integer_24,
             integer_25,
             integer_26,
             integer_27,
             --integer_28,
             date_08,
             char_01_09
      FROM pb_varname
     WHERE identifier = '006'
/

/****** Object:  View INSTALLMENTS    Script Date: 11/28/00 11:48:52 AM ******/

CREATE OR REPLACE VIEW installments
(
	policy_date_time,
	renewal_code,
	policy_number,
	pol_eff_date,
	pol_exp_date,
	installment_date,
	status_1,
	user_id,
	agency_id,
	client_number,
	annual_premium
)
AS
	SELECT p.policy_date_time,
			 p.renewal_code,
			 p.policy_number,
			 p.pol_eff_date,
			 p.pol_exp_date,
			 p.installment_date,
			 r.status_1,
			 r.user_id,
			 p.agency_id,
			 p.client_number,
			 p.annual_premium
	  FROM register r, policy p
	 WHERE	  r.policy_number = p.policy_number
			 AND p.policy_date_time = r.policy_date_time
			 AND r.status_1 != '1'
			 AND r.status_1 != '6'
			 AND r.status_1 != '7'
			 AND r.status_1 != 'A'
			 AND r.status_2 = '0'
			 AND r.status_3 = 'A'
			 AND p.installment_date != p.pol_exp_date
/

/****** Object:  View EXPIRATIONS    Script Date: 11/28/00 11:48:52 AM ******/

CREATE OR REPLACE VIEW expirations
(
	policy_date_time,
	renewal_code,
	policy_number,
	pol_eff_date,
	pol_exp_date,
	installment_date,
	agency_id,
	client_number,
	annual_premium,
	status_1,
	user_id
)
AS
	SELECT p.policy_date_time,
			 p.renewal_code,
			 p.policy_number,
			 p.pol_eff_date,
			 p.pol_exp_date,
			 p.installment_date,
			 p.agency_id,
			 p.client_number,
			 p.annual_premium,
			 r.status_1,
			 r.user_id
	  FROM register r, policy p
	 WHERE	  r.policy_number = p.policy_number
			 AND p.policy_date_time = r.policy_date_time
			 AND r.status_3 = 'A'
			 AND r.status_1 != '6'
/

/****** Object:  View DS_POLICY_SEARCH    Script Date: 11/28/00 11:48:50 AM ******/

CREATE OR REPLACE VIEW ds_policy_search
(
	salesrep_id,
	annual_premium,
	billed_premium,
	policy_number,
	pol_eff_date,
	pol_exp_date,
	pol_inc_date,
	pol_rating_buro,
	pol_reporting_buro,
	pol_term_date,
	pol_forms_buro,
	pol_written_by,
	pol_source,
	pol_type,
	dividend,
	renewal_code,
	prior_policy,
	client_number,
	change_eff_date,
	policy_date_time,
	cancel_reason,
	cancel_method,
	std_commission,
	commission_rate,
	billed_premium_id,
	new_or_renewal,
	installment_date,
	written_premium,
	company_name,
	manually_rated,
	reporting_date,
	nonpay_cancel,
	underwriter_cancel,
	underwriter_reason,
	pend_cancel_date,
	agency_id,
	quote_ind,
	non_renewal_reason,
	reinstate_date,
	short_rate_factor,
	annualized_premium,
	q_policy_number,
	q_policy_datetime,
	status_date_1,
	status_1,
	check_out,
	user_id,
	status_2,
	status_3,
	portfolio_set,
	reason_suspended,
	reinstates,
	rescissions
)
AS
	SELECT p.salesrep_id,
			 p.annual_premium,
			 p.billed_premium,
			 p.policy_number,
			 p.pol_eff_date,
			 p.pol_exp_date,
			 p.pol_inc_date,
			 p.pol_rating_buro,
			 p.pol_reporting_buro,
			 p.pol_term_date,
			 p.pol_forms_buro,
			 p.pol_written_by,
			 p.pol_source,
			 p.pol_type,
			 p.dividend,
			 p.renewal_code,
			 p.prior_policy,
			 p.client_number,
			 p.change_eff_date,
			 p.policy_date_time,
			 p.cancel_reason,
			 p.cancel_method,
			 p.std_commission,
			 p.commission_rate,
			 p.billed_premium_id,
			 p.new_or_renewal,
			 p.installment_date,
			 p.written_premium,
			 p.company_name,
			 p.manually_rated,
			 p.reporting_date,
			 p.nonpay_cancel,
			 p.underwriter_cancel,
			 p.underwriter_reason,
			 p.pend_cancel_date,
			 p.agency_id,
			 p.quote_ind,
			 p.non_renewal_reason,
			 p.reinstate_date,
			 p.short_rate_factor,
			 p.annualized_premium,
			 p.q_policy_number,
			 p.q_policy_datetime,
			 r.status_date_1,
			 r.status_1,
			 r.check_out,
			 r.user_id,
			 r.status_2,
			 r.status_3,
			 r.portfolio_set,
			 r.reason_suspended,
			 r.reinstates,
			 r.rescissions
	  FROM policy p, register r
	 WHERE	  p.policy_number = r.policy_number
			 AND p.policy_date_time = r.policy_date_time
/

/****** Object:  View POLICY_VIEW    Script Date: 11/28/00 11:48:52 AM ******/

CREATE OR REPLACE VIEW policy_view
(
	policy_number,
	client_number,
	pol_type,
	annual_premium,
	agency_id,
	status_1,
	cov_a_amount,
	commission_pct
)
AS
	SELECT p.policy_number,
			 p.client_number,
			 p.pol_type,
			 p.annual_premium,
			 p.agency_id,
			 r.status_1,
			 d.cov_a_amount,
			 d.commission_pct
	  FROM register r, policy p, hodetail d
	 WHERE	  p.policy_number = d.policy_number
			 AND p.policy_number = r.policy_number
			 AND p.policy_date_time = d.policy_date_time
			 AND p.policy_date_time = r.policy_date_time
/

/****** Object:  View BLV_POLICY_ACCOUNT    Script Date: 11/28/00 11:48:49 AM ******/

CREATE OR REPLACE VIEW blv_policy_account
(
	policy_number,
	pol_eff_date,
	upper_agency_name,
	agency_name,
	master_account_id,
	account_name,
	agency_record_type,
	effective_date,
	termination_date,
	account_type,
	billplan,
	owner_type
)
AS
	SELECT	DISTINCT
				p.policy_number,
				p.pol_eff_date,
				UPPER (a.agency_name),
				a.agency_name,
				m.master_account_id,
				m.account_name,
				a.agency_record_type,
				m.effective_date,
				m.termination_date,
				m.account_type,
				m.billplan,
				m.owner_type
		 FROM agency a, bl_master_account m, policy p, bl_acct_activity v
		WHERE 	 m.master_account_id = v.master_account_id
				AND a.agency_number = m.owner_id
				AND p.agency_id = a.agency_id
	GROUP BY p.policy_number,
				p.pol_eff_date,
				a.agency_name,
				m.master_account_id,
				m.account_name,
				a.agency_record_type,
				m.effective_date,
				m.termination_date,
				m.account_type,
				m.billplan,
				m.owner_type
/

/****** Object:  View BLV_MSTR_ACCOUNT    Script Date: 11/28/00 11:48:49 AM ******/

CREATE OR REPLACE VIEW blv_mstr_account
(
	account_owner,
	account_name,
	account_type,
	account_type_desc,
	billplan,
	billplan_desc,
	effective_date,
	last_change,
	master_account_id,
	associated_default,
	owner_id,
	owner_type,
	status,
	termination_date,
	administrator_id,
	user_id,
	associated_id,
	auto_cancel
)
AS
	SELECT aa.account_owner,
			 ma.account_name,
			 ma.account_type,
			 s.description,
			 ma.billplan,
			 l.description,
			 ma.effective_date,
			 ma.last_change,
			 ma.master_account_id,
			 aa.associated_default,
			 ma.owner_id,
			 ma.owner_type,
			 ma.status,
			 ma.termination_date,
			 ma.administrator_id,
			 ma.user_id,
			 aa.associated_id,
			 ma.auto_cancel
	  FROM bl_master_account ma,
			 bl_account_assoc aa,
			 edit_long_code l,
			 edit_short_code s
	 WHERE	  ma.master_account_id = aa.master_account_id
			 AND l.tbname = 'BILLPLAN'
			 AND l.name = 'BILLPLAN'
			 AND billplan = l.code
			 AND s.tbname = 'BL_MASTER_ACCOUNT'
			 AND s.name = 'ACCOUNT_TYPE'
			 AND account_type = s.code
/
/
/

/****** Object:  View BLV_MSTR_ACCT_AGNT    Script Date: 11/28/00 11:48:53 AM ******/

CREATE OR REPLACE VIEW blv_mstr_acct_agnt
(
	account_owner,
	account_name,
	account_name_up,
	account_type,
	account_type_desc,
	billplan,
	billplan_desc,
	effective_date,
	last_change,
	master_account_id,
	associated_default,
	owner_id,
	owner_type,
	status,
	termination_date,
	administrator_id,
	user_id,
	associated_id,
	auto_cancel,
	associated_name,
	associated_name_up
)
AS
	SELECT ma.account_owner,
			 ma.account_name,
			 UPPER (ma.account_name),
			 ma.account_type,
			 ma.account_type_desc,
			 ma.billplan,
			 ma.billplan_desc,
			 ma.effective_date,
			 ma.last_change,
			 ma.master_account_id,
			 ma.associated_default,
			 ma.owner_id,
			 ma.owner_type,
			 ma.status,
			 ma.termination_date,
			 ma.administrator_id,
			 ma.user_id,
			 ma.associated_id,
			 ma.auto_cancel,
			 a.agency_name,
			 UPPER (a.agency_name)
	  FROM blv_mstr_account ma, agency a
	 WHERE ma.owner_type = '1' AND ma.associated_id = a.agency_number
/
/
/

CREATE OR REPLACE VIEW blv_agency_address
(
	master_account_id,
	name,
	streetaddress,
	address2,
	citystate,
	zipcode
)
AS
	SELECT ma.master_account_id,
			 agency_name,
			 agency_addr_1,
			 agency_addr_2,
			 agency_city + ', ' + agency_state,
			 agency_zip_code
	  FROM bl_master_account ma, agency a
	 WHERE a.agency_number = ma.owner_id
/
/
/

/****** Object:  View BLV_BIDPDS    Script Date: 11/28/00 11:48:48 AM ******/

CREATE OR REPLACE VIEW blv_bidpds
(
	master_account_id,
	policy_number,
	portfolio_set,
	client_name,
	policy_eff_date,
	bill_group_id,
	bill_group,
	item_bill_date,
	gross,
	net,
	pay_gross,
	pay_net,
	in_dispute_count,
	comment_counter,
	status_count
)
AS
	SELECT	a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date,
				i.bill_group_id,
				b.bill_group_name,
				i.item_bill_date,
				SUM (i.gross_amount),
				SUM (i.net_amount),
				SUM (p.pay_gross),
				SUM (p.pay_net),
				SUM (i.in_dispute),
				SUM (i.comment_count),
				SUM (i.open_flag)
		 FROM bl_acct_activity a,
				bl_bill_group b,
					bl_acct_item i
				LEFT OUTER JOIN
					bl_bipay p
				ON i.item_id = p.the_key
		WHERE 	 a.activity_id = i.activity_id
				AND i.bill_group_id = b.bill_group_id
				AND a.activity_group != 'R'
	GROUP BY a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date,
				i.bill_group_id,
				b.bill_group_name,
				i.item_bill_date
/
/
/

CREATE OR REPLACE VIEW blv_clnt_stmt_prnt
(
	bill_stmt_id,
	incl_disputed,
	master_account_id,
	bill_date,
	due_date,
	prior_bill_date,
	prior_due_date,
	run_date_time,
	company_code,
	policy_number,
	portfolio_set,
	pol_eff_date,
	client_name,
	activity_abbrev,
	activity_desc,
	bill_group,
	create_date_time,
	item_bill_date,
	gross_amount,
	in_dispute,
	owner_id
)
AS
	SELECT p.bill_stmt_id,
			 r.incl_disputed,
			 r.master_account_id,
			 r.bill_date,
			 r.due_date,
			 r.prior_bill_date,
			 r.prior_due_date,
			 r.run_date_time,
			 r.company_code,
			 a.policy_number,
			 a.portfolio_set,
			 a.pol_eff_date,
			 a.client_name,
			 c.activity_abbrev,
			 c.activity_desc,
			 g.bill_group,
			 i.create_date_time,
			 i.item_bill_date,
			 i.gross_amount,
			 i.in_dispute,
			 m.owner_id
	  FROM bl_bill_stmt_print p,
			 bl_bill_stmt_run r,
			 bl_bill_stmt_item t,
			 bl_acct_activity a,
			 bl_acct_item i,
			 bl_bill_group g,
			 bl_activity_code c,
			 bl_master_account m
	 WHERE	  p.bill_stmt_id = r.bill_stmt_id
			 AND r.bill_stmt_id = t.bill_stmt_id
			 AND r.master_account_id = a.master_account_id
			 AND a.master_account_id = m.master_account_id
			 AND a.activity_id = i.activity_id
			 AND a.activity_type = c.activity_type
			 AND a.activity_group = c.activity_group
			 AND i.bill_group_id = g.bill_group_id
			 AND i.item_id = t.item_id
/

CREATE OR REPLACE VIEW blv_bill_stmt_prnt
(
	bill_stmt_id,
	incl_disputed,
	master_account_id,
	bill_date,
	due_date,
	prior_bill_date,
	prior_due_date,
	run_date_time,
	company_code,
	policy_number,
	portfolio_set,
	pol_eff_date,
	client_name,
	activity_abbrev,
	activity_desc,
	bill_group,
	create_date_time,
	item_bill_date,
	commission_rate,
	gross_amount,
	net_amount,
	in_dispute,
	agency_name,
	agency_addr_1,
	agency_city,
	agency_state,
	agency_zip_code
)
AS
	SELECT p.bill_stmt_id,
			 r.incl_disputed,
			 r.master_account_id,
			 r.bill_date,
			 r.due_date,
			 r.prior_bill_date,
			 r.prior_due_date,
			 r.run_date_time,
			 r.company_code,
			 a.policy_number,
			 a.portfolio_set,
			 a.pol_eff_date,
			 a.client_name,
			 c.activity_abbrev,
			 c.activity_desc,
			 g.bill_group,
			 i.create_date_time,
			 i.item_bill_date,
			 i.commission_rate,
			 i.gross_amount,
			 i.net_amount,
			 i.in_dispute,
			 y.agency_name,
			 y.agency_addr_1,
			 y.agency_city,
			 y.agency_state,
			 y.agency_zip_code
	  FROM bl_bill_stmt_print p,
			 bl_bill_stmt_run r,
			 bl_bill_stmt_item t,
			 bl_acct_activity a,
			 bl_acct_item i,
			 bl_bill_group g,
			 bl_activity_code c,
			 bl_master_account m,
			 agency y
	 WHERE	  p.bill_stmt_id = r.bill_stmt_id
			 AND r.bill_stmt_id = t.bill_stmt_id
			 AND r.master_account_id = a.master_account_id
			 AND a.master_account_id = m.master_account_id
			 AND a.activity_id = i.activity_id
			 AND a.activity_type = c.activity_type
			 AND a.activity_group = c.activity_group
			 AND m.owner_id = y.agency_number
			 AND i.bill_group_id = g.bill_group_id
			 AND i.item_id = t.item_id
/

/****** Object:  View BLV_BIDUE    Script Date: 11/28/00 11:48:49 AM ******/

CREATE OR REPLACE VIEW blv_bidue
(
	item_id,
	link_id,
	master_account_id,
	activity_id,
	policy_number,
	portfolio_set,
	client_name,
	policy_eff_date,
	bill_group_id,
	bill_group,
	bill_date,
	item_due_date,
	activity_eff_date,
	activity_type,
	activity_group,
	activity_abbrev,
	activity_desc,
	create_date_time,
	rcv_type,
	rcv_eff_date,
	rcv_activity_abrv,
	rcv_activity_desc,
	gross,
	comm_rate,
	net,
	pay_gross,
	pay_comm_rate,
	pay_net,
	in_dispute,
	comment_count,
	installment_num,
	open_flag,
	paydist_id,
	paydist_status,
	session_id,
	psession_id,
	item_gross_balance,
	item_net_balance
)
AS
	SELECT i.item_id,
			 i.link_id,
			 a.master_account_id,
			 a.activity_id,
			 a.policy_number,
			 a.portfolio_set,
			 a.client_name,
			 a.pol_eff_date,
			 i.bill_group_id,
			 b.bill_group_name,
			 i.item_bill_date,
			 i.item_due_date,
			 a.activity_eff_date,
			 a.activity_type,
			 a.activity_group,
			 c.activity_abbrev,
			 c.activity_desc,
			 i.create_date_time,
			 i.rcv_type,
			 i.rcv_eff_date,
			 c2.activity_abbrev,
			 c2.activity_desc,
			 i.gross_amount,
			 i.commission_rate,
			 i.net_amount,
			 p.pay_gross,
			 p.pay_comm_rate,
			 p.pay_net,
			 i.in_dispute,
			 i.comment_count,
			 a.installment_num,
			 i.open_flag,
			 a.paydist_id,
			 a.paydist_status,
			 a.session_id,
			 p.psession_id,
			 i.gross_balance,
			 i.net_balance
	  FROM bl_acct_activity a,
			 bl_bill_group b,
			 bl_activity_code c,
			 bl_activity_code c2,
				 bl_acct_item i
			 LEFT OUTER JOIN
				 bl_bipay p
			 ON i.item_id = p.the_key
	 WHERE	  i.activity_id = a.activity_id
			 AND a.activity_group != 'R'
			 AND i.bill_group_id = b.bill_group_id
			 AND a.activity_group = c.activity_group
			 AND a.activity_type = c.activity_type
			 AND 'R' = c2.activity_group
			 AND i.rcv_type = c2.activity_type
/
/
/

/****** Object:  View BLV_BIDPAS    Script Date: 11/28/00 11:48:48 AM ******/

CREATE OR REPLACE VIEW blv_bidpas
(
	master_account_id,
	policy_number,
	portfolio_set,
	client_name,
	policy_eff_date,
	activity_id,
	activity_eff_date,
	activity_type,
	activity_group,
	activity_abbrev,
	activity_desc,
	item_bill_date,
	gross,
	net,
	pay_gross,
	pay_net,
	in_dispute_count,
	comment_counter,
	status_count
)
AS
	SELECT	a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date,
				a.activity_id,
				a.activity_eff_date,
				a.activity_type,
				a.activity_group,
				c.activity_abbrev,
				c.activity_desc,
				i.item_bill_date,
				SUM (i.gross_amount),
				SUM (i.net_amount),
				SUM (p.pay_gross),
				SUM (p.pay_net),
				SUM (i.in_dispute),
				SUM (i.comment_count),
				SUM (i.open_flag)
		 FROM bl_acct_activity a,
				bl_activity_code c,
					bl_acct_item i
				LEFT OUTER JOIN
					bl_bipay p
				ON i.item_id = p.the_key
		WHERE 	 a.activity_id = i.activity_id
				AND a.activity_group = c.activity_group
				AND a.activity_type = c.activity_type
				AND a.activity_group != 'R'
	GROUP BY a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date,
				a.activity_id,
				a.activity_eff_date,
				a.activity_type,
				a.activity_group,
				c.activity_abbrev,
				c.activity_desc,
				i.item_bill_date
/
/
/

/****** Object:  View BLV_BIDPADS    Script Date: 11/28/00 11:48:48 AM ******/

CREATE OR REPLACE VIEW blv_bidpads
(
	master_account_id,
	policy_number,
	portfolio_set,
	client_name,
	policy_eff_date,
	activity_id,
	activity_eff_date,
	activity_type,
	activity_group,
	activity_abbrev,
	activity_desc,
	bill_group_id,
	item_bill_date,
	gross,
	net,
	pay_gross,
	pay_net,
	in_dispute_count,
	comment_counter,
	status_count
)
AS
	SELECT	a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date,
				a.activity_id,
				a.activity_eff_date,
				a.activity_type,
				a.activity_group,
				c.activity_abbrev,
				c.activity_desc,
				i.bill_group_id,
				i.item_bill_date,
				SUM (i.gross_amount),
				SUM (i.net_amount),
				SUM (p.pay_gross),
				SUM (p.pay_net),
				SUM (i.in_dispute),
				SUM (i.comment_count),
				SUM (i.open_flag)
		 FROM bl_acct_activity a,
				bl_bill_group b,
				bl_activity_code c,
					bl_acct_item i
				LEFT OUTER JOIN
					bl_bipay p
				ON i.item_id = p.the_key
		WHERE 	 a.activity_id = i.activity_id
				AND a.activity_group = c.activity_group
				AND a.activity_type = c.activity_type
				AND i.bill_group_id = b.bill_group_id
				AND a.activity_group != 'R'
	GROUP BY a.master_account_id,
				a.policy_number,
				a.portfolio_set,
				a.client_name,
				a.pol_eff_date,
				a.activity_id,
				a.activity_eff_date,
				a.activity_type,
				a.activity_group,
				c.activity_abbrev,
				c.activity_desc,
				i.bill_group_id,
				i.item_bill_date
/
/

CREATE OR REPLACE VIEW sv_policy_search
AS
	SELECT p.policy_number,
			 p.pol_alt_id,
			 p.policy_date_time,
			 psl.portfolio_set,
			 c.fname1,
			 c.lname1,
			 a.agency_name,
			 a.agency_id,
			 p.pol_eff_date,
			 p.pol_exp_date,
			 c.client_type,
			 c.client_number,
			 CASE client_type
				 WHEN 'C'
				 THEN
						RTRIM (nvl (c.lname1, NULL))
					 + ' '
					 + RTRIM (nvl (c.fname1, NULL))
				 ELSE
						RTRIM (nvl (c.fname1, NULL))
					 + ' '
					 + RTRIM (nvl (c.lname1, NULL))
			 END
				 AS client_name
	  FROM policy p
			 INNER JOIN sv_portfolio_set_last psl
				 ON	  p.policy_number = psl.policy_number
					 AND p.policy_date_time = psl.cur_policy_date_time
			 LEFT OUTER JOIN client c
				 ON p.client_number = c.client_number
			 LEFT OUTER JOIN agency a
				 ON p.agency_id = a.agency_id
/
/
/

/****** Object:  View BLV_CLIENT_ADDRESS    Script Date: 11/28/00 11:48:49 AM ******/

CREATE OR REPLACE VIEW blv_client_address
(
	policy_number,
	client_number,
	lname1,
	fname1,
	init1,
	streetaddress,
	address2,
	city,
	state,
	zipcode
)
AS
	SELECT DISTINCT
			 policy_number,
			 c.client_number,
			 lname1,
			 fname1,
			 init1,
			 address1,
			 address2,
			 city,
			 state,
			 zipcode
	  FROM policy p, client c, address a
	 WHERE	  c.client_number = a.client_number
			 AND p.client_number = c.client_number
/

CREATE OR REPLACE VIEW e0043_liab_lmt
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	location,
	liab_lmt,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 long_code_5,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02K' AND termination_date IS NULL
/
/
/

--SELECT * FROM ENDORSEMENT_VIEWS WHERE IDENTIFIER = '02J'

CREATE OR REPLACE VIEW e0042_reg_proc
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	reg_prem,
	reg_prem_total,
	reg_disc,
	effective_date,
	termination_date,
	reg_limit,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 premium_1,
			 premium_2,
			 decimal_amount_1,
			 effective_date,
			 termination_date,
			 short_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02J' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0041_0507
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	description,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02D' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0040_0507
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01k' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0039_0507
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01j' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0038_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	premium,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 premium_1,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01X' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0037_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01R' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0036_0507
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	age_at_retirement,
	applies_to_all,
	years_of_coverage,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 short_code_1,
			 short_code_2,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01i' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0035_0206
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00L' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0034_0206
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '003' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0033_0206
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00K' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0032_0206
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	county_cd,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 long_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00J' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0031_0206_0
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00H' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0030_0206
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	from_dt,
	to_dt,
	location,
	liab_lmt,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 date_1,
			 date_2,
			 description,
			 long_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00G' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0029_0206
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	from_dt,
	to_dt,
	state,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 date_1,
			 date_2,
			 long_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00F' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0028_0206
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00Z' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0026_limitation
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01V' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0026_0206
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	opt_wording,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 short_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00U' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0025_0604_cfp
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	tail_prem,
	effective_date,
	termination_date,
	erp_dt,
	insured,
	tail_cov,
	liab_lmt,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 premium_1,
			 effective_date,
			 termination_date,
			 date_1,
			 name_and_address,
			 short_code_1,
			 long_code_1,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01g' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0025_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	tail_prem,
	effective_date,
	termination_date,
	erp_dt,
	insured,
	tail_cov,
	liab_lmt,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 premium_1,
			 effective_date,
			 termination_date,
			 date_1,
			 name_and_address,
			 short_code_1,
			 long_code_1,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '002' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0023_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01N' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0022_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	addl_ins,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 name_and_address,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '001' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0021_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	term_dt,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 date_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00E' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0020_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	annual_prem,
	effective_date,
	termination_date,
	proc_incl,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 premium_2,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00D' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0019_0604_pol
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	insured,
	endo_id,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 name_and_address,
			 description,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01Z' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0019_0604_exp
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	endo_id,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01a' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0018_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00T' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0017_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	loa_adjustment,
	effective_date,
	termination_date,
	to_dt,
	leave_reason,
	pct_prem_waived,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 premium_1,
			 effective_date,
			 termination_date,
			 date_1,
			 short_code_1,
			 short_code_2,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00C' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0016_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	from_dt,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 date_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00B' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0015_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	employer,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00A' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0014_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	covered_facilities,
	applies_to_all,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 short_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01h' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0013_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	proc_excl,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '009' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0012_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	facilities_excl,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '008' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0010_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	from_dt,
	to_dt,
	locum_tenens,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 date_1,
			 date_2,
			 name_and_address,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '007' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0007_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01M' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW e0001_0604
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	cancel_dt,
	location,
	covg_limited,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 date_1,
			 name_and_address,
			 short_code_1,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01c' AND termination_date IS NULL
/
/
/

/****** Object:  View CLIENT_NAMES    Script Date: 11/28/00 11:48:50 AM ******/
/

/****** Object:  View BLV_AGENCY_ACCOUNT    Script Date: 11/28/00 11:48:53 AM ******/

CREATE OR REPLACE VIEW blv_agency_account
(
	upper_agency_name,
	agency_name,
	master_account_id,
	account_name,
	agency_record_type,
	effective_date,
	termination_date,
	account_type,
	billplan,
	owner_type,
	account_owner
)
AS
	SELECT associated_name_up,
			 associated_name,
			 master_account_id,
			 account_name,
			 ' ',
			 effective_date,
			 termination_date,
			 account_type,
			 billplan,
			 owner_type,
			 account_owner
	  FROM blv_mstr_acct_agnt
	UNION
	SELECT UPPER (c.coll_a_name),
			 c.coll_a_name,
			 m.master_account_id,
			 m.account_name,
			 ' ',
			 m.effective_date,
			 m.termination_date,
			 m.account_type,
			 m.billplan,
			 m.owner_type,
			 1
	  FROM bl_master_account m, bl_coll_agency c
	 WHERE m.owner_type = '3' AND m.owner_id = c.coll_agency_id
	UNION
	SELECT UPPER (c.client_name),
			 c.client_name,
			 m.master_account_id,
			 m.account_name,
			 ' ',
			 m.effective_date,
			 m.termination_date,
			 m.account_type,
			 m.billplan,
			 m.owner_type,
			 1
	  FROM bl_master_account m, client_names c
	 WHERE m.owner_type = '2' AND m.owner_id = c.client_number
/
/
/

/****** Object:  View CLIENT_ADDRESS    Script Date: 11/28/00 11:48:50 AM ******/

CREATE OR REPLACE VIEW client_address
(
	client_type,
	client_number,
	lfi1_lfi2_names,
	fname1,
	init1,
	lname1,
	fname2,
	init2,
	lname2,
	prefix1,
	prefix2,
	suffix1,
	suffix2,
	address1,
	address2,
	address3,
	city,
	state,
	zipcode,
	country,
	address_type
)
AS
	SELECT client_type,
			 client.client_number,
			 SUBSTR (
				 LTRIM (
					 CASE
						 WHEN 	RTRIM (fname2) IS NOT NULL
								OR RTRIM (init2) IS NOT NULL
								OR RTRIM (lname2) IS NOT NULL
						 THEN
								 CASE NVL (LENGTH (RTRIM (lname1)), 0)
									 WHEN 0 THEN RTRIM (' ')
									 ELSE RTRIM (NVL (lname1, ' ')) || ','
								 END
							 || RTRIM (' ' || RTRIM (NVL (prefix1, ' ')))
							 || RTRIM (' ' || RTRIM (NVL (fname1, ' ')))
							 || CASE NVL (LENGTH (RTRIM (init1)), 0)
									 WHEN 1 THEN RTRIM (' ' || init1) || '.'
									 WHEN 0 THEN RTRIM (' ')
									 ELSE RTRIM (' ' || init1)
								 END
							 || RTRIM (' ' || RTRIM (NVL (suffix1, ' ')))
							 || ' &'
							 || CASE NVL (LENGTH (RTRIM (lname2)), 0)
									 WHEN 1 THEN RTRIM (' ' || lname2) || ','
									 WHEN 0 THEN RTRIM (' ')
									 ELSE RTRIM (' ' || lname2)
								 END
							 || RTRIM (' ' || NVL (prefix2, ' '))
							 || RTRIM (' ' || NVL (fname2, ' '))
							 || CASE NVL (LENGTH (RTRIM (init2)), 0)
									 WHEN 1 THEN RTRIM (' ' || init2) || '.'
									 WHEN 0 THEN RTRIM (' ')
									 ELSE RTRIM (' ' || init2)
								 END
							 || RTRIM (' ' || NVL (suffix2, ' '))
						 ELSE
								 CASE NVL (LENGTH (RTRIM (lname1)), 0)
									 WHEN 0 THEN RTRIM (' ')
									 ELSE RTRIM (' ' || lname1) || ','
								 END
							 || RTRIM (' ' || RTRIM (NVL (prefix1, ' ')))
							 || RTRIM (' ' || RTRIM (NVL (fname1, ' ')))
							 || CASE NVL (LENGTH (RTRIM (init1)), 0)
									 WHEN 1 THEN RTRIM (' ' || init1) || '.'
									 WHEN 0 THEN RTRIM (' ')
									 ELSE RTRIM (' ' || init1)
								 END
							 || RTRIM (' ' || NVL (suffix1, ' '))
					 END),
				 1,
				 254),
			 fname1,
			 init1,
			 lname1,
			 fname2,
			 init2,
			 lname2,
			 prefix1,
			 prefix2,
			 suffix1,
			 suffix2,
			 address1,
			 address2,
			 address3,
			 city,
			 state,
			 zipcode,
			 country,
			 address_type
	  FROM client, address
	 WHERE client.client_number = address.client_number;
/

CREATE OR REPLACE VIEW chg_prac
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	explain,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00h' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW blv_company_addr
(
	company_code,
	company_name,
	company_addr_1,
	company_addr_2,
	company_addr_3,
	company_city,
	company_state,
	company_zip
)
AS
	SELECT e.code,
			 e.description,
			 c.company_addr1,
			 c.company_addr2,
			 c.company_addr3,
			 c.company_city,
			 c.company_state,
			 c.company_zip
	  FROM edit_short_code e, bl_company_address c
	 WHERE e.name = 'COMPANY_NAME' AND e.code = c.company
/
/
/

CREATE OR REPLACE VIEW bill_addr_not_mail
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	address,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 name_and_address,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '005' AND termination_date IS NULL
/
/
/

/****** Object:  View BLV_ACCOUNTPLAN    Script Date: 11/28/00 11:48:48 AM ******/

CREATE OR REPLACE VIEW blv_accountplan
(
	parm_value,
	billplan,
	master_account_id,
	parm_name
)
AS
	SELECT parm_value, b.billplan, a.master_account_id, b.parm_name
	  FROM bl_master_account a, billplan b
	 WHERE (b.billplan = a.billplan) OR (b.billplan = 'A**')
/
/
/

CREATE OR REPLACE VIEW anc_prof_with_cov
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	eff_date,
	exp_date,
	ins_co,
	liab_lmt,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 date_1,
			 date_2,
			 description,
			 long_code_2,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00a' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW anc_prof_nocov_cnt
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	explain,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00e' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW anc_prof_nocov
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	name,
	type_ancillary,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 long_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00b' AND termination_date IS NULL
/

CREATE OR REPLACE VIEW ancillary_prof
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	number_,
	effective_date,
	termination_date,
	type_ancillary,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 decimal_amount_1,
			 effective_date,
			 termination_date,
			 long_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '018' AND termination_date IS NULL;

/****** Object:  View AGENCY_VIEW    Script Date: 11/28/00 11:48:47 AM ******/

CREATE OR REPLACE VIEW agency_view
(
	agency_id,
	agency_id_01,
	agency_id_02,
	agency_id_03,
	agency_id_04,
	agency_id_05,
	agency_id_06,
	agency_id_07,
	agency_id_08,
	agency_id_09,
	agency_id_10,
	agency_name,
	agency_addr_1,
	agency_addr_2,
	agency_addr_3,
	agency_zip_code,
	agency_comm_level
)
AS
	SELECT agency_id,
			 agency_id_01,
			 agency_id_02,
			 agency_id_03,
			 agency_id_04,
			 agency_id_05,
			 agency_id_06,
			 agency_id_07,
			 agency_id_08,
			 agency_id_09,
			 agency_id_10,
			 agency_name,
			 agency_addr_1,
			 agency_addr_2,
			 agency_addr_3,
			 agency_zip_code,
			 agency_comm_level
	  FROM agency
/
/
/

CREATE OR REPLACE VIEW addl_off_loc
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	pct_practice,
	effective_date,
	termination_date,
	office_loc,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 decimal_amount_1,
			 effective_date,
			 termination_date,
			 name_and_address,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00f' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW aac_detail
(
	beach_district,
	liab_lmt,
	carrier_name,
	amd_quote_nbr,
	acct_mgr,
	county_code,
	retro_date,
	app_submit_dt,
	app_declined_dt,
	comm_pct,
	pol_prem,
	comm_amt,
	division,
	fire_district_code,
	identifier,
	liab_rate_group,
	plan_code,
	policy_date_time,
	policy_form,
	policy_number,
	rating_state,
	state_code,
	sub_county_code,
	territory_code_01,
	territory_code_02,
	territory_code_03,
	territory_code_04,
	territory_code_05,
	territory_code_06,
	territory_code_07,
	territory_code_08,
	territory_code_09,
	town_code
)
AS
	SELECT beach_district,
			 char_03_01,
			 char_desc_01,
			 char_desc_02,
			 char_desc_03,
			 county_code,
			 date_01,
			 date_02,
			 date_03,
			 decimal_14_2_01,
			 decimal_15_0_01,
			 decimal_15_0_02,
			 division,
			 fire_district_code,
			 identifier,
			 liab_rate_group,
			 plan_code,
			 policy_date_time,
			 policy_form,
			 policy_number,
			 rating_state,
			 state_code,
			 sub_county_code,
			 territory_code_01,
			 territory_code_02,
			 territory_code_03,
			 territory_code_04,
			 territory_code_05,
			 territory_code_06,
			 territory_code_07,
			 territory_code_08,
			 territory_code_09,
			 town_code
	  FROM pb_detail
	 WHERE identifier = '005'
/
/
/

CREATE OR REPLACE VIEW voc_train_cont
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	explain,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01K' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW voc_train
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	facility,
	month_adm,
	year_adm,
	month_compl,
	year_compl,
	type_ancillary,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 long_code_6,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01J' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW settled_indemnity
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	amt_yourself,
	amt_codefendant,
	total_amt,
	effective_date,
	termination_date,
	date_settled,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 decimal_amount_1,
			 decimal_amount_2,
			 decimal_amount_3,
			 effective_date,
			 termination_date,
			 date_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01G' AND termination_date IS NULL
/
/
/

/****** Object:  View SCOR_AUTO_DRIVER    Script Date: 11/28/00 11:48:52 AM ******/

CREATE OR REPLACE VIEW scor_auto_driver
(
	driver_class,
	date_time,
	policy_number,
	driver_scor,
	sequence_number
)
AS
	SELECT class_code_4,
			 policy_date_time,
			 policy_number,
			 primary_factor,
			 sequence_number
	  FROM auto_drivers
	 WHERE identifier = '008'
/
/
/

CREATE OR REPLACE VIEW undergrad
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	school,
	degree,
	month_adm,
	year_adm,
	month_compl,
	year_compl,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 short_code_1,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01S' AND termination_date IS NULL
/

CREATE OR REPLACE VIEW solo_pa_mmap
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	name,
	cov_solo_pa,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 short_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02C' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW retro_dt
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	retro_dt,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 date_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01A' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW residency
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	facility,
	month_adm,
	year_adm,
	month_compl,
	year_compl,
	specialty,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 long_code_6,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00t' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW premium_adjust
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	prem_adj,
	effective_date,
	termination_date,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 premium_1,
			 effective_date,
			 termination_date,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00S' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW pct_prac_other
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	explain,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00g' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW quote_tail_cov
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	tail_prem,
	effective_date,
	termination_date,
	insured,
	cert_mail_receipt,
	liab_lmt,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 premium_1,
			 effective_date,
			 termination_date,
			 name_and_address,
			 description,
			 long_code_1,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '019' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW quote_subject_to
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	commission,
	effective_date,
	termination_date,
	subj_to,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 decimal_amount_1,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00X' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW quote_excl
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	exclusions,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01b' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW quote_declination
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	reason,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00x' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW qt_add_on_subj_to
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	subj_to,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01f' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW prof_aff
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	prof_aff,
	beg_month,
	beg_year,
	end_month,
	end_year,
	specialty,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 long_code_6,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '010' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW proc_not_cust
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	proc_explan,
	prim_assist,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '013' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW prior_prac_phys
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	name,
	beg_month,
	beg_year,
	end_month,
	end_year,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00k' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW prior_prac_ent
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	name,
	beg_month,
	beg_year,
	end_month,
	end_year,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00j' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW prior_prac_diff
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	explain,
	beg_month,
	beg_year,
	end_month,
	end_year,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00l' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW prior_cov_res
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	begin_dt,
	end_dt,
	explain,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 date_1,
			 date_2,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00m' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW prior_carriers
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	prem,
	effective_date,
	termination_date,
	eff_dt,
	exp_dt,
	retro_dt,
	name,
	type_form,
	liab_lmt,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 decimal_amount_1,
			 effective_date,
			 termination_date,
			 date_1,
			 date_2,
			 date_5,
			 description,
			 short_code_2,
			 long_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '015' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW prior_acts_exp
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	explain,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00n' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW phys_with_cov
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	eff_date,
	exp_date,
	ins_co,
	liab_lmt,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 date_1,
			 date_2,
			 description,
			 long_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01Q' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW phys_assoc_claim
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	name,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01F' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW open_claim
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	status,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01I' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW ent_assoc_claim
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	name,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01E' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW entity_partners
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	name,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01L' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW hos_ext_rep
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	tail_prem,
	effective_date,
	termination_date,
	erp_dt,
	insured,
	tail_cov,
	liab_lmt,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 premium_1,
			 effective_date,
			 termination_date,
			 date_1,
			 name_and_address,
			 short_code_1,
			 long_code_1,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02H' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW hos_amendatory
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	general_changes,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02E' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW hostail_amendatory
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	general_changes,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02F' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW hosp_priv
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	hospital,
	nature_priv,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00i' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW home_addr
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	home_addr,
	cell_phone,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 name_and_address,
			 description,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00c' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW nonconsec_train_co
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	explain,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00w' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW nonconsec_train
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	facility,
	month_adm,
	year_adm,
	month_compl,
	year_compl,
	specialty,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 long_code_6,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00v' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW narc_lic
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	narc_lic_nbr,
	state,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 long_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01P' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW graduate
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	school,
	degree,
	month_adm,
	year_adm,
	month_compl,
	year_compl,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 short_code_1,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01T' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW gl_amendatory
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	general_changes,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02G' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW fellowship
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	facility,
	month_adm,
	year_adm,
	month_compl,
	year_compl,
	specialty,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 long_code_6,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00u' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW explain_rel
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	explain,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01W' AND termination_date IS NULL
/
/
/
/

--we're not bringing over the underlying table, so I'm commenting out this view
--CREATE OR REPLACE VIEW mpl_app_info
--(
--	beach_district,
--	hosp_priv,
--	prior_acts,
--	chg_prac,
--	prior_prac,
--	prior_prac_diff,
--	prior_cov_rest,
--	tail_curr_carr,
--	prior_acts_exp,
--	grad_schl,
--	fellowship,
--	non_consec_train,
--	curr_train,
--	ecfmg_cert,
--	first_prac,
--	board_cert,
--	failed_exam,
--	board_elig,
--	claim_suit,
--	rpt_clm,
--	surgery,
--	proc_not_cust,
--	prior_carrier,
--	addl_prof_info_1,
--	addl_prof_info_2,
--	addl_prof_info_3,
--	addl_prof_info_4,
--	addl_prof_info_5,
--	addl_prof_info_6,
--	addl_prof_info_7,
--	addl_prof_info_8,
--	addl_prof_info_9,
--	addl_prof_info_10,
--	addl_prof_info_11,
--	addl_prof_info_12,
--	addl_prof_info_13,
--	addl_prof_info_14,
--	addl_prof_info_15,
--	addl_prof_info_16,
--	addl_prof_info_17,
--	addl_prof_info_18,
--	addl_prof_info_19,
--	addl_prof_info_20,
--	addl_prof_info_21,
--	addl_prof_info_22,
--	addl_prof_info_23,
--	addl_prof_info_24,
--	addl_prof_info_25,
--	addl_prof_info_26,
--	addl_prof_info_27,
--	addl_prof_info_28,
--	addl_prof_info_29,
--	addl_prof_info_30,
--	exposure_type,
--	relation_name_ins,
--	part_name_ins,
--	med_schl,
--	internship,
--	residency,
--	voc_train,
--	entity_struct,
--	addl_med_lic,
--	addl_narc_lic,
--	abortions,
--	acupunct,
--	adenoid,
--	anesth,
--	angio,
--	append,
--	band,
--	bleph,
--	bronch,
--	cesar,
--	chema,
--	circum,
--	colon,
--	cosm_inj,
--	cosm_elect,
--	cosm_recon,
--	cryo,
--	d_c,
--	derma,
--	electro,
--	endo_proc,
--	endo_retro,
--	esoph,
--	facelift,
--	fertility,
--	gastric,
--	hair,
--	hemorr,
--	hernias,
--	hyperbaric,
--	hyster,
--	hypnosis,
--	iud,
--	lapar,
--	lasers,
--	lipo,
--	lumbar,
--	biopsy,
--	mohs,
--	ob_del,
--	ob_del_other,
--	off_xray,
--	open_red,
--	pain_mgmt,
--	prenatal,
--	radial_ker,
--	radiation,
--	spinal_anesth,
--	spinal_surg,
--	tele,
--	tonsil,
--	thoracic,
--	tubal,
--	transplant,
--	trig_point,
--	vascular,
--	vasect,
--	vbac,
--	state,
--	explain_relation,
--	anc_daily_duties,
--	explain_struct,
--	med_lic_nbr,
--	narc_lic_nbr,
--	county_code,
--	lic_exp_date,
--	board_elig_until,
--	board_elig_exam,
--	division,
--	effective_date,
--	fire_district_code,
--	identifier,
--	liab_rate_group,
--	plan_code,
--	policy_date_time,
--	policy_number,
--	rating_state,
--	reference_number,
--	sequence_number,
--	seqnbr,
--	failed_exam_nbr,
--	nbr_open_clm,
--	nbr_closed_clm,
--	tot_nbr_clm,
--	nbr_surg_ann,
--	work_comp_inj,
--	state_code,
--	sub_county_code,
--	termination_date,
--	territory_code_01,
--	territory_code_02,
--	territory_code_03,
--	territory_code_04,
--	territory_code_05,
--	territory_code_06,
--	territory_code_07,
--	territory_code_08,
--	territory_code_09,
--	town_code
--)
--AS
--	SELECT beach_district,
--			 char_01_01,
--			 char_01_02,
--			 char_01_03,
--			 char_01_04,
--			 char_01_05,
--			 char_01_06,
--			 char_01_07,
--			 char_01_08,
--			 char_01_09,
--			 char_01_10,
--			 char_01_100,
--			 char_01_101,
--			 char_01_102,
--			 char_01_103,
--			 char_01_104,
--			 char_01_105,
--			 char_01_106,
--			 char_01_107,
--			 char_01_108,
--			 char_01_109,
--			 char_01_11,
--			 char_01_110,
--			 char_01_111,
--			 char_01_112,
--			 char_01_113,
--			 char_01_114,
--			 char_01_115,
--			 char_01_116,
--			 char_01_117,
--			 char_01_118,
--			 char_01_119,
--			 char_01_12,
--			 char_01_120,
--			 char_01_121,
--			 char_01_122,
--			 char_01_123,
--			 char_01_124,
--			 char_01_125,
--			 char_01_126,
--			 char_01_127,
--			 char_01_128,
--			 char_01_129,
--			 char_01_13,
--			 char_01_130,
--			 char_01_131,
--			 char_01_132,
--			 char_01_133,
--			 char_01_134,
--			 char_01_135,
--			 char_01_136,
--			 char_01_137,
--			 char_01_138,
--			 char_01_139,
--			 char_01_140,
--			 char_01_141,
--			 char_01_142,
--			 char_01_143,
--			 char_01_144,
--			 char_01_145,
--			 char_01_146,
--			 char_01_147,
--			 char_01_148,
--			 char_01_16,
--			 char_01_17,
--			 char_01_18,
--			 char_01_19,
--			 char_01_20,
--			 char_01_21,
--			 char_01_22,
--			 char_01_23,
--			 char_01_24,
--			 char_01_25,
--			 char_01_26,
--			 char_01_27,
--			 char_01_28,
--			 char_01_29,
--			 char_01_30,
--			 char_01_31,
--			 char_01_32,
--			 char_01_33,
--			 char_01_34,
--			 char_01_35,
--			 char_01_36,
--			 char_01_37,
--			 char_01_38,
--			 char_01_39,
--			 char_01_40,
--			 char_01_41,
--			 char_01_42,
--			 char_01_43,
--			 char_01_44,
--			 char_01_45,
--			 char_01_46,
--			 char_01_47,
--			 char_01_48,
--			 char_01_49,
--			 char_01_50,
--			 char_01_51,
--			 char_01_52,
--			 char_01_53,
--			 char_01_54,
--			 char_01_55,
--			 char_01_56,
--			 char_01_57,
--			 char_01_58,
--			 char_01_59,
--			 char_01_60,
--			 char_01_61,
--			 char_01_62,
--			 char_01_63,
--			 char_01_64,
--			 char_01_65,
--			 char_01_66,
--			 char_01_67,
--			 char_01_68,
--			 char_01_69,
--			 char_01_70,
--			 char_01_71,
--			 char_01_72,
--			 char_01_73,
--			 char_03_01,
--			 char_desc_02,
--			 char_desc_03,
--			 char_desc_04,
--			 char_desc_05,
--			 char_desc_06,
--			 county_code,
--			 date_01,
--			 date_02,
--			 date_03,
--			 division,
--			 effective_date,
--			 fire_district_code,
--			 identifier,
--			 liab_rate_group,
--			 plan_code,
--			 policy_date_time,
--			 policy_number,
--			 rating_state,
--			 reference_number,
--			 sequence_number,
--			 smallint_01,
--			 smallint_02,
--			 smallint_03,
--			 smallint_04,
--			 smallint_05,
--			 smallint_06,
--			 smallint_07,
--			 state_code,
--			 sub_county_code,
--			 termination_date,
--			 territory_code_01,
--			 territory_code_02,
--			 territory_code_03,
--			 territory_code_04,
--			 territory_code_05,
--			 territory_code_06,
--			 territory_code_07,
--			 territory_code_08,
--			 territory_code_09,
--			 town_code
--	  FROM pb_vardata1
--	 WHERE identifier = '003'
--/

CREATE OR REPLACE VIEW mmap_shared_lmt
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	premium,
	effective_date,
	termination_date,
	description,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 premium_1,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01z' AND termination_date IS NULL
/

CREATE OR REPLACE VIEW mpl_detail
(
	beach_district,
	bill_addr_eq_mail,
	policy_type,
	underwriter,
	app_status,
	rev_for_ren_reas,
	deduct_applies,
	type_deduct,
	referral_source,
	reinsurance,
	continuous,
	app_status_quote,
	underwriter_asst,
	printed_e0022,
	ded_applies_all,
	printed_e0033,
	med_staff_cov,
	med_staff_no_cov,
	med_staff_seek_cov,
	override_rt_eff_dt,
	ancil_prof,
	rate_eff_dt,
	save_rate_eff_dt,
	company,
	fac_type,
	account_type,
	account_desc,
	eft_label,
	policy_label,
	group_agg,
	deductible,
	plan_code_subset,
	app_submitted_by,
	per_ins_deduct,
	depository_branch,
	depository_city,
	depository_state,
	lowest_lmt,
	cell_phone,
	save_mail_addr_1,
	prior_first_name,
	prior_last_name,
	prior_initial,
	app_compl_by,
	app_ent_by,
	routing_nbr,
	account_nbr,
	depository_zipcode,
	depository_name,
	county_code,
	group_disc,
	group_a_rate,
	rein_prem,
	division,
	fire_district_code,
	identifier,
	policy_year,
	policy_prem,
	next_endo_nbr,
	new_next_endo_nbr,
	tot_phys_prem,
	tot_anc_prem,
	tot_ent_prem,
	tot_phys_base,
	tot_phys_adj,
	tot_crna_base,
	tot_pa_base,
	tot_oth_anc_base,
	tot_anc_adj,
	tot_tail_prem,
	prem_adj,
	quote_prem,
	tot_phys_tmb_prem,
	end_seq_num,
	ann_prem_rate_yr_2,
	ann_prem_rate_yr_3,
	ann_prem_rate_yr_4,
	liab_rate_group,
	plan_code,
	policy_date_time,
	policy_form,
	policy_number,
	rating_state,
	state_code,
	sub_county_code,
	territory_code_01,
	territory_code_02,
	territory_code_03,
	territory_code_04,
	territory_code_05,
	territory_code_06,
	territory_code_07,
	territory_code_08,
	territory_code_09,
	town_code,
	app_received_dt,
	qt_add_on_eff_dt,
	purchase_grp,
	reg_proc
)
AS
	SELECT beach_district,
			 char_01_02,
			 char_01_03,
			 char_01_04,
			 char_01_05,
			 char_01_06,
			 char_01_07,
			 char_01_08,
			 char_01_09,
			 char_01_10,
			 char_01_100,
			 char_01_101,
			 char_01_102,
			 char_01_103,
			 char_01_104,
			 char_01_105,
			 char_01_106,
			 char_01_107,
			 char_01_108,
			 char_01_109,
			 char_01_11,
			 char_01_110,
			 char_01_111,
			 char_01_112,
			 char_01_113,
			 char_01_114,
			 char_01_115,
			 char_01_117,
			 char_01_118,
			 char_03_01,
			 char_03_02,
			 char_03_03,
			 char_03_04,
			 char_03_05,
			 char_03_07,
			 char_03_08,
			 char_03_09,
			 char_03_100,
			 char_desc_01,
			 char_desc_02,
			 char_desc_03,
			 char_desc_04,
			 char_desc_05,
			 char_desc_06,
			 char_desc_07,
			 char_desc_09,
			 char_desc_10,
			 char_desc_11,
			 char_desc_12,
			 county_code,
			 decimal_14_2_01,
			 decimal_14_2_02,
			 decimal_14_2_03,
			 division,
			 fire_district_code,
			 identifier,
			 integer_01,
			 integer_03,
			 integer_04,
			 integer_05,
			 integer_06,
			 integer_07,
			 integer_08,
			 integer_09,
			 integer_10,
			 integer_100,
			 integer_11,
			 integer_12,
			 integer_13,
			 integer_14,
			 integer_15,
			 integer_16,
			 integer_17,
			 integer_18,
			 integer_19,
			 integer_20,
			 integer_21,
			 liab_rate_group,
			 plan_code,
			 policy_date_time,
			 policy_form,
			 policy_number,
			 rating_state,
			 state_code,
			 sub_county_code,
			 territory_code_01,
			 territory_code_02,
			 territory_code_03,
			 territory_code_04,
			 territory_code_05,
			 territory_code_06,
			 territory_code_07,
			 territory_code_08,
			 territory_code_09,
			 town_code,
			 date_01,
			 date_03,
			 char_01_12,
			 char_01_119
	  FROM pb_detail
	 WHERE identifier = '001'
/

--we're commenting out fields that have all nulls and are being dropped in the export of data from sqlserver to oracle
CREATE OR REPLACE VIEW mpl_exposure
(
    address_number,
--    beach_district,
    exposure_type,
    md_do,
    rating_terr,
    type_lmt,
    deduct_applies,
    new_to_practice,
    solo_pa,
    slot,
    policy_type,
    cancel_type,
    assoc_endo,
    qt_add_on,
    anc_man_override,
    pol_exp_type,
    printed_e0010,
    printed_e0012,
    printed_e0013,
    printed_e0015,
    printed_e0016,
    printed_e0020,
    printed_e0030,
    printed_e0031_0,
    printed_e0031_pm,
    printed_e0032,
    printed_e0033,
    printed_e0029,
    save_rating_terr,
    printed_e0017,
--    rating_info,
--    rating_adj,
    assoc_endo2,
    ratio,
    rating_county,
    liab_lmt,
    group_agg,
    deductible,
    type_ancillary,
    specialty,
    save_liab_lmt,
    save_specialty,
--    erp_lmt,
    prior_acts_lmt,
    per_ins_deduct,
    sub_specialty,
    tmb_limit,
    curr_liab_lmt,
    prior_first_name,
    /*prior_last_name,
    prior_initial,
    save_address1,
    save_address2,
    save_address3,
    save_city,
    save_state,
    save_zipcode,*/
    save_solo_pa,
    client_number,
--    county_code,
    retro_dt,
    save_chg_date,
--    save_pol_dt_time,
    save_retro_dt,
    prev_chg_date,
    qt_add_on_eff_dt,
--    e0017_loa_prorata,
    inc_limit_fctr,
    rating_yr_fctr,
    anc_fctr,
    group_disc,
    exper_disc,
    risk_mgmt,
    discount_1,
    discount_2,
    discount_3,
    manual_blending,
    save_group_disc,
    save_exper_disc,
    save_risk_mgmt,
    save_discount_1,
    save_discount_2,
    save_discount_3,
    save_man_blending,
    ent_prem_pct,
    phys_vic_pct,
    e0017_loa_adj,
    claims_made_debit,
    tail_not_bought,
    grievance,
    felony_misdemeanor,
    sick,
    review,
    new_practice,
    part_time,
    abuse,
    license,
    misconduct,
    relapse,
    alteration,
    no_coverage,
    fda_approved,
    expiring_coverage,
    imp_phys_prog,
    not_renewed,
    no_risk_magmt,
    other_debit,
    other_credit,
    loss_frequency,
    longevity_credit,
    cme_risk_magmt,
    vic_liab_debit,
    misc_debit_1,
    misc_debit_2,
    misc_debit_3,
    misc_debit_4,
    misc_debit_5,
    misc_debit_6,
    misc_debit_7,
    misc_debit_8,
    misc_debit_9,
    misc_debit_10,
--    division,
    effective_date,
--    fire_district_code,
    identifier,
    new_prac_disc,
    practice_hours,
    part_time_disc,
    save_chg_prem_ann,
    save_chg_prem_pro,
    prev_chg_prem_pro,
    prev_chg_prem_ann,
    save_new_prac_disc,
    save_part_tm_disc,
    exp_prem,
    phys_base_prem,
    phys_rating_adj,
    crna_base_prem,
    pa_base_prem,
    oth_anc_base_prem,
    anc_rating_adj,
--    entity_prem,
    phys_tmb_prem,
    class_rate,
    base_prem,
    rating_adj_prem,
    ancil_man_prem,
    qt_add_on_prem,
--    liab_rate_group,
    plan_code,
    policy_date_time,
    policy_number,
    rating_state,
    reference_number,
    sequence_number,
    exp_nbr,
    pct_prim_loc,
    spec_pct_prac,
    sub_spec_pct_prac,
    patient_load,
    pct_prac_nh,
    pct_prac_rehab,
    pct_prac_other,
    year_curr_loc,
    slot_position,
--    state_code,
--    sub_county_code,
    termination_date,
    territory_code_01,
    /*territory_code_02,
    territory_code_03,
    territory_code_04,
    territory_code_05,
    territory_code_06,
    territory_code_07,
    territory_code_08,
    territory_code_09,
    town_code,*/
    med_lic_nbr,
    exp_inc_date,
    reg_proc_prem,
    prem_endt_addon,
    lic_exp_date
)
AS
    SELECT address_number,
             --beach_district,
             char_01_01,
             char_01_02,
             char_01_03,
             char_01_04,
             char_01_05,
             char_01_06,
             char_01_07,
             char_01_08,
             char_01_09,
             char_01_10,
             char_01_100,
             char_01_101,
             char_01_102,
             char_01_103,
             char_01_104,
             char_01_105,
             char_01_106,
             char_01_107,
             char_01_108,
             char_01_109,
             char_01_11,
             char_01_110,
             char_01_111,
             char_01_112,
             char_01_113,
             char_01_114,
             char_01_115,
             char_01_116,
             --char_01_117,
             --char_01_118,
             char_01_119,
             char_01_12,
             char_03_01,
             char_03_02,
             char_03_03,
             char_03_04,
             char_03_05,
             char_03_06,
             char_03_07,
             char_03_08,
             --char_03_09,
             char_03_10,
             char_03_100,
             char_03_101,
             char_03_102,
             char_03_103,
             char_desc_03,
             /*char_desc_04,
             char_desc_05,
             char_desc_06,
             char_desc_07,
             char_desc_08,
             char_desc_09,
             char_desc_10,
             char_desc_11,*/
             char_desc_12,
             client_number,
             --county_code,
             date_01,
             date_02,
             --date_03,
             date_04,
             date_05,
             date_06,
             --decimal_08_5_01,
             decimal_14_2_01,
             decimal_14_2_02,
             decimal_14_2_03,
             decimal_14_2_04,
             decimal_14_2_05,
             decimal_14_2_06,
             decimal_14_2_07,
             decimal_14_2_08,
             decimal_14_2_09,
             decimal_14_2_100,
             decimal_14_2_101,
             decimal_14_2_102,
             decimal_14_2_103,
             decimal_14_2_104,
             decimal_14_2_105,
             decimal_14_2_106,
             decimal_14_2_108,
             decimal_14_2_109,
             decimal_14_2_11,
             decimal_14_2_111,
             decimal_14_2_112,
             decimal_14_2_113,
             decimal_14_2_114,
             decimal_14_2_115,
             decimal_14_2_116,
             decimal_14_2_117,
             decimal_14_2_118,
             decimal_14_2_119,
             decimal_14_2_120,
             decimal_14_2_121,
             decimal_14_2_122,
             decimal_14_2_123,
             decimal_14_2_124,
             decimal_14_2_125,
             decimal_14_2_126,
             decimal_14_2_127,
             decimal_14_2_128,
             decimal_14_2_129,
             decimal_14_2_130,
             decimal_14_2_131,
             decimal_14_2_132,
             decimal_14_2_133,
             decimal_14_2_135,
             decimal_14_2_136,
             decimal_14_2_138,
             decimal_14_2_139,
             decimal_14_2_140,
             decimal_14_2_141,
             decimal_14_2_142,
             decimal_14_2_143,
             decimal_14_2_144,
             decimal_14_2_145,
             decimal_14_2_146,
             decimal_14_2_147,
             decimal_14_2_148,
             --division,
             effective_date,
             --fire_district_code,
             identifier,
             integer_02,
             integer_03,
             integer_04,
             integer_05,
             integer_06,
             integer_07,
             integer_08,
             integer_11,
             integer_19,
             integer_20,
             integer_22,
             integer_23,
             integer_24,
             integer_25,
             integer_26,
             integer_27,
             --integer_28,
             integer_29,
             integer_31,
             integer_32,
             integer_33,
             integer_34,
             integer_36,
             --liab_rate_group,
             plan_code,
             policy_date_time,
             policy_number,
             rating_state,
             reference_number,
             sequence_number,
             smallint_01,
             smallint_02,
             smallint_03,
             smallint_04,
             smallint_05,
             smallint_06,
             smallint_07,
             smallint_08,
             smallint_09,
             smallint_10,
             --state_code,
             --sub_county_code,
             termination_date,
             territory_code_01,
             /*territory_code_02,
             territory_code_03,
             territory_code_04,
             territory_code_05,
             territory_code_06,
             territory_code_07,
             territory_code_08,
             territory_code_09,
             town_code,*/
             char_desc_01,
             date_08,
             decimal_14_2_150,
             decimal_14_2_152,
             date_07
      FROM pb_varname
     WHERE identifier = '002'
/

CREATE OR REPLACE VIEW mmap_separate_lmt
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	premium,
	effective_date,
	termination_date,
	description,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 premium_1,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01y' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW mmap_part_time
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	general_changes,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02A' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW mmap_ext_rep
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	tail_prem,
	effective_date,
	termination_date,
	erp_dt,
	insured,
	tail_cov,
	liab_lmt,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 premium_1,
			 effective_date,
			 termination_date,
			 date_1,
			 name_and_address,
			 short_code_1,
			 long_code_1,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01x' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW mmap_exclusion
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	description,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01m' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW mmap_cancellation
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	description,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '02B' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW mmap_amendatory
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	general_changes,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01l' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW med_schl
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	school,
	degree,
	month_adm,
	year_adm,
	month_compl,
	year_compl,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 short_code_1,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01U' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW long_name
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	named_insured,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01d' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW licensure
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	exp_date,
	lic_nbr,
	state,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 date_1,
			 description,
			 long_code_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01B' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW judgement_plaint
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	amt_yourself,
	amt_codefendant,
	total_amt,
	effective_date,
	termination_date,
	date_verdict,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 decimal_amount_1,
			 decimal_amount_2,
			 decimal_amount_3,
			 effective_date,
			 termination_date,
			 date_1,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01H' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW internship
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	facility,
	month_adm,
	year_adm,
	month_compl,
	year_compl,
	specialty,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 long_code_6,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00s' AND termination_date IS NULL
/
/
/

/****** Object:  View DS_VALID_ENDORSE    Script Date: 11/28/00 11:48:51 AM ******/

CREATE OR REPLACE VIEW ds_valid_endorse
(
	plan_code,
	view_name,
	identifier,
	number_of_occurs,
	mandatory,
	version_effective,
	version_terminate,
	pol_type,
	next_endorsement,
	name_is_client,
	desc_type,
	table_sequence,
	description,
	process_level,
	details_exist,
	plan_code_subset,
	display_only,
	sched_endorsement
)
AS
	SELECT v.source_value,
			 e.view_name,
			 e.identifier,
			 e.number_of_occurs,
			 e.mandatory,
			 e.version_effective,
			 e.version_terminate,
			 e.pol_type,
			 e.next_endorsement,
			 e.name_is_client,
			 e.desc_type,
			 e.table_sequence,
			 e.description,
			 e.process_level,
			 e.details_exist,
			 e.plan_code_subset,
			 e.display_only,
			 e.sched_endorsement
	  FROM endorsement_views e, phnx_validation v
	 WHERE	  v.source_field = 'PLAN_CODE'
			 AND v.related_field = 'IDENTIFIER'
			 AND e.identifier = v.related_value
/
/
/

/****** Object:  View DS_VALID_EDIT_SHRT    Script Date: 11/28/00 11:48:51 AM ******/

CREATE OR REPLACE VIEW ds_valid_edit_shrt
(
	plan_code,
	source_table,
	source_field,
	related_table,
	related_field,
	source_value,
	related_value,
	sequence_number,
	description
)
AS
	SELECT v.plan_code,
			 v.source_table,
			 v.source_field,
			 v.related_table,
			 v.related_field,
			 v.source_value,
			 v.related_value,
			 v.validation_level,
			 e.description
	  FROM phnx_validation v, edit_short_code e
	 WHERE	  v.source_table = e.tbname
			 AND v.source_field = e.name
			 AND v.source_value = e.code
/
/
/

/****** Object:  View DS_VALID_EDIT_RNGE    Script Date: 11/28/00 11:48:51 AM ******/

CREATE OR REPLACE VIEW ds_valid_edit_rnge
(
	plan_code,
	source_table,
	source_field,
	related_table,
	related_field,
	source_value,
	related_value,
	sequence_number,
	description,
	range_1,
	range_2,
	is_range
)
AS
	SELECT v.plan_code,
			 v.source_table,
			 v.source_field,
			 v.related_table,
			 v.related_field,
			 v.source_value,
			 v.related_value,
			 v.validation_level,
			 e.description,
			 e.range_value_1,
			 e.range_value_2,
			 (e.range_value_1 - e.range_value_2)
	  FROM phnx_validation v, edit_range_code e
	 WHERE	  v.source_table = e.tbname
			 AND v.source_field = e.name
			 AND v.source_value = e.code
/
/
/

/****** Object:  View DS_VALID_EDIT_LONG    Script Date: 11/28/00 11:48:51 AM ******/

CREATE OR REPLACE VIEW ds_valid_edit_long
(
	plan_code,
	source_table,
	source_field,
	related_table,
	related_field,
	source_value,
	related_value,
	sequence_number,
	description
)
AS
	SELECT v.plan_code,
			 v.source_table,
			 v.source_field,
			 v.related_table,
			 v.related_field,
			 v.source_value,
			 v.related_value,
			 v.validation_level,
			 e.description
	  FROM phnx_validation v, edit_long_code e
	 WHERE	  v.source_table = e.tbname
			 AND v.source_field = e.name
			 AND v.source_value = e.code
/
/
/

/****** Object:  View DS_TOWN_DIVISIONS    Script Date: 11/28/00 11:48:51 AM ******/

CREATE OR REPLACE VIEW ds_town_divisions
(
	state_code,
	town_code,
	town_name,
	division,
	division_name,
	beach_district,
	liab_rate_group,
	county_code,
	zip_code,
	sub_county_code,
	fire_district_code,
	county_name
)
AS
	SELECT t.state_code,
			 t.town_code,
			 t.description,
			 d.division,
			 d.description,
			 t.beach_district,
			 t.liab_rate_group,
			 t.county_code,
			 t.zip_code,
			 t.sub_county_code,
			 t.fire_district_code,
			 c.county_name
	  FROM	 town t
			 LEFT OUTER JOIN
				 city_division d
			 ON d.state_code = t.state_code AND d.town_code = t.town_code,
			 county c
	 WHERE t.state_code = c.state_code AND t.county_code = c.county_code
/
/
/

/****** Object:  View DS_TOWNS_UNIQUE    Script Date: 11/28/00 11:48:50 AM ******/

CREATE OR REPLACE VIEW ds_towns_unique
(
	state_code,
	town_name
)
AS
	SELECT DISTINCT state_code, description FROM town
/
/
/

/****** Object:  View DS_TOWNS_COUNTIES    Script Date: 11/28/00 11:48:50 AM ******/

CREATE OR REPLACE VIEW ds_towns_counties
(
	state_code,
	town_code,
	town_name,
	beach_district,
	liab_rate_group,
	county_code,
	zip_code,
	sub_county_code,
	fire_district_code,
	county_name
)
AS
	SELECT t.state_code,
			 t.town_code,
			 t.description,
			 t.beach_district,
			 t.liab_rate_group,
			 t.county_code,
			 t.zip_code,
			 t.sub_county_code,
			 t.fire_district_code,
			 c.county_name
	  FROM town t, county c
	 WHERE t.state_code = c.state_code AND t.county_code = c.county_code
/
/
/

/****** Object:  View DS_STATES    Script Date: 11/28/00 11:48:50 AM ******/

CREATE OR REPLACE VIEW ds_states (state_code)
AS
	SELECT DISTINCT state_code FROM town
/
/
/

CREATE OR REPLACE VIEW deleted_exposures
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	exp_prem,
	slot_position,
	exper_disc,
	risk_mgmt,
	manual_blending,
	discount_1,
	discount_2,
	discount_3,
	effective_date,
	termination_date,
	retro_date,
	exp_eff_date,
	exp_term_date,
	insured_name,
	solo_pa_name,
	exposure_type,
	rating_terr,
	cancel_type,
	type_lmt,
	specialty,
	liab_lmt,
	type_ancillary,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 premium_1,
			 premium_2,
			 decimal_amount_1,
			 decimal_amount_2,
			 decimal_amount_3,
			 decimal_amount_7,
			 decimal_amount_8,
			 decimal_amount_9,
			 effective_date,
			 termination_date,
			 date_1,
			 date_2,
			 date_5,
			 name_and_address,
			 description,
			 short_code_1,
			 short_code_2,
			 short_code_5,
			 short_code_6,
			 long_code_1,
			 long_code_2,
			 long_code_5,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01Y' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW curr_train_cont
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	type_program,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00z' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW curr_train
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	facility,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '00y' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW cross_reference
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	insured,
	descr,
	address_number,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 name_and_address,
			 description,
			 address_number,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01e' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW board_elig
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	effective_date,
	termination_date,
	elig_until,
	exam,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 effective_date,
			 termination_date,
			 date_1,
			 date_2,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '01O' AND termination_date IS NULL
/
/
/

CREATE OR REPLACE VIEW board_cert
(
	policy_number,
	renewal_plan,
	reference_number,
	decimal_amount_4,
	decimal_amount_5,
	decimal_amount_6,
	premium_4,
	premium_5,
	premium_6,
	premium_7,
	premium_8,
	premium_9,
	premium_10,
	premium_11,
	premium_12,
	date_3,
	date_4,
	long_code_3,
	long_code_4,
	short_code_3,
	short_code_4,
	sequence_number,
	effective_date,
	termination_date,
	board_cert_dt,
	by_whom,
	policy_date_time
)
AS
	SELECT policy_number,
			 renewal_plan,
			 reference_number,
			 decimal_amount_4,
			 decimal_amount_5,
			 decimal_amount_6,
			 premium_4,
			 premium_5,
			 premium_6,
			 premium_7,
			 premium_8,
			 premium_9,
			 premium_10,
			 premium_11,
			 premium_12,
			 date_3,
			 date_4,
			 long_code_3,
			 long_code_4,
			 short_code_3,
			 short_code_4,
			 sequence_number,
			 effective_date,
			 termination_date,
			 date_1,
			 description,
			 policy_date_time
	  FROM endorsement
	 WHERE identifier = '011' AND termination_date IS NULL
/
/
/

/****** Object:  View DS_PLAN_DESC    Script Date: 11/28/00 11:48:50 AM ******/

CREATE OR REPLACE VIEW ds_plan_desc
(
	pol_type,
	policy_form,
	plan_code,
	state_code,
	effective_date,
	pol_type_desc,
	form_desc,
	plan_desc,
	expire_date
)
AS
	SELECT p.type_of_policy,
			 p.policy_form,
			 p.plan_code,
			 p.state_code,
			 p.effective_date,
			 es1.description,
			 es2.description,
			 el.description,
			 p.expire_date
	  FROM phnx_plan p,
			 edit_short_code es1,
			 edit_short_code es2,
			 edit_long_code el
	 WHERE	  es1.name = 'POL_TYPE'
			 AND es1.code = p.type_of_policy
			 AND es2.name = 'POLICY_FORM'
			 AND es2.tbname = el.tbname
			 AND es2.code = p.policy_form
			 AND el.name = 'PLAN_CODE'
			 AND el.code = p.plan_code
/
/
/

/****** Object:  View DS_BILLPLAN    Script Date: 11/28/00 11:48:50 AM ******/

CREATE OR REPLACE VIEW ds_billplan
(
	billplan,
	parm_name,
	parm_value,
	change_date_time,
	user_id,
	parm_type,
	parm_length,
	parm_scale,
	parm_desc,
	parm_group,
	parm_index
)
AS
	SELECT b.billplan,
			 b.parm_name,
			 b.parm_value,
			 b.change_date_time,
			 b.user_id,
			 c.parm_type,
			 c.parm_length,
			 c.parm_scale,
			 c.parm_desc,
			 c.parm_group,
			 c.parm_index
	  FROM billplan b, billplan_ctrl c
	 WHERE c.parm_name = b.parm_name
/

DECLARE
	CURSOR grant_cur
	IS
		SELECT view_name FROM user_views;
BEGIN
	FOR cur_row IN grant_cur
	LOOP
		EXECUTE IMMEDIATE
			('grant select on ' || cur_row.view_name || ' to novaprd');
	END LOOP;
END;
/

alter table claim disable constraint claim_fk1;
alter table claim_acord disable constraint claim_acord_fk1;
alter table claim_contacts disable constraint claim_contacts_fk1;
alter table claim_forms disable constraint claim_forms_fk1;
alter table claim_notes disable constraint claim_notes_fk1;
alter table claim_photos disable constraint claim_photos_fk1;
alter table claim_subro disable constraint claim_subro_fk1;
alter table fav_claims disable constraint fav_claims_fk1;
alter table sm_occurrence1 disable constraint sm_occurrence1_fk1;
alter table CLAIM_FT_PMT_ITEM disable constraint CLAIM_FT_PMT_ITEM_FK1;
alter table CLAIM_FT_RECEIPT disable constraint CLAIM_FT_RECEIPT_FK1;
alter table CLAIM_FT_RECBLE disable constraint CLAIM_FT_RECBLE_FK1;
alter table CLAIM_FNCL_TRANS disable constraint CLAIM_FNCL_TRANS_FK1;
alter table MONTH_CLAIMS disable constraint MONTH_CLAIMS_FK1;
alter table CLAIM_SUM disable constraint CLAIM_SUM_FK1;
alter table CLAIM_FT_RESERVE disable constraint CLAIM_FT_RESERVE_FK1;
alter table CLAIM_LITIGATION disable constraint CLAIM_LITIGATN_FK1;
alter table salvage disable constraint salvage_FK1;
alter table sm_claim1 disable constraint sm_claim1_FK1;
alter table CLAIM_FT_PAYMENT disable constraint CLAIM_FT_PAYMENT_FK1;
alter table CLAIM_DEFENDANT disable constraint CLAIM_DEFENDANT_FK;

PROMPT END - $Workfile: CNV_CD37909.sql$ ($Revision: 6$)

