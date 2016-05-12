PROMPT BEGIN - $Workfile: CNV_CX37909.sql$ ($Revision: 1$)

alter table claim enable constraint claim_fk1;
alter table claim_acord enable constraint claim_acord_fk1;
alter table claim_contacts enable constraint claim_contacts_fk1;
alter table claim_forms enable constraint claim_forms_fk1;
alter table claim_notes enable constraint claim_notes_fk1;
alter table claim_photos enable constraint claim_photos_fk1;
alter table claim_subro enable constraint claim_subro_fk1;
alter table fav_claims enable constraint fav_claims_fk1;
alter table sm_occurrence1 enable constraint sm_occurrence1_fk1;
alter table claim_ft_pmt_item enable constraint claim_ft_pmt_item_fk1;
alter table claim_ft_receipt enable constraint claim_ft_receipt_fk1;
alter table claim_ft_recble enable constraint claim_ft_recble_fk1;
alter table claim_fncl_trans enable constraint claim_fncl_trans_fk1;
alter table month_claims enable constraint month_claims_fk1;
alter table claim_sum enable constraint claim_sum_fk1;
alter table claim_ft_reserve enable constraint claim_ft_reserve_fk1;
alter table claim_litigation enable constraint claim_litigatn_fk1;
alter table salvage enable constraint salvage_fk1;
alter table sm_claim1 enable constraint sm_claim1_fk1;
alter table claim_ft_payment enable constraint claim_ft_payment_fk1;
alter table claim_defendant enable constraint claim_defendant_fk;

PROMPT END - $Workfile: CNV_CX37909.sql$ ($Revision: 1$)
