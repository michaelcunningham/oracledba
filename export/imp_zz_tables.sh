#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

. /dba/admin/dba.lib

dmp_dir=/dba/export/dmp
log_dir=/dba/export/log
log_date=`date +%a`

tns=`get_tns_from_orasid $ORACLE_SID`

username=novaprd
userpwd=`get_user_pwd $tns $username`

exp_file=${dmp_dir}/tdcprd_${username}_zz_tables.dmp
log_file=${log_dir}/${ORACLE_SID}_${username}_zz_tables_${log_date}.log

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit
fi

imp $username/$userpwd@$tns file=${exp_file} log=${log_file} ignore=y \
tables=zz_cl_endorsement_in_effect,zz_document,zz_em_employee_orignum,zz_eom_insured_snapshot, \
zz_eom_policy_snapshot,zz_me_eom_eas_performance_work,zz_n2n_conversion,zz_n2p_conversion, \
zz_ot_docs,zz_pa_star_conv_coverage,zz_pa_star_conv_debit_credit,zz_pa_star_conv_insured, \
zz_pa_star_conv_segment,zz_pa_star_conv_status,zz_s2n_address_type_issue,zz_s2n_balance, \
zz_s2n_charge,zz_s2n_commission_common,zz_s2n_commission_coverage,zz_s2n_commission_debit, \
zz_s2n_convert_exclude_ptrans,zz_s2n_divdend_bal_fix,zz_s2n_driver,zz_s2n_financial_bal, \
zz_s2n_insured_mismatch,zz_s2n_ipn_bal,zz_s2n_log,zz_s2n_msng_pol, \
zz_s2n_msng_pol_by_comp,zz_s2n_msng_pol_terms,zz_s2n_msng_pol_term_by_comp,zz_s2n_pa_coverage, \
zz_s2n_pa_debit_credit,zz_s2n_pa_document,zz_s2n_pa_financial_trans,zz_s2n_pa_form, \
zz_s2n_pa_form_info,zz_s2n_pa_insured,zz_s2n_pa_insured_detail,zz_s2n_pa_segment, \
zz_s2n_pa_specialty,zz_s2n_pa_work_order,zz_s2n_pi_by_seg,zz_s2n_request_35_vs_40_1, \
zz_s2n_runstop,zz_s2n_seg_date_btw_pol_term,zz_s2n_seg_date_continuity,zz_s2n_term_date_continuity, \
zz_s2n_term_date_mismatch,zz_w_rein_claim,zz_w_rein_claimant,zz_w_rein_claimant_history, \
zz_w_rein_claim_history,zz_w_rein_claim_support,zz_w_rein_claim_support_hist,zz_w_rein_claim_trans, \
zz_w_rein_claim_trans_history,zz_w_rein_dw_claimant

