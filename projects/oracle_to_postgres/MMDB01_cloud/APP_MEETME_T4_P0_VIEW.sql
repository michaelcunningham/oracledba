CREATE OR REPLACE FORCE VIEW APP_MEETME_T4_P0_VIEW
(TBL, USER_ID, INTERESTED_UID, INTERESTED, DATE_MODIFIED)
BEQUEATH DEFINER
AS 
select 't0' tbl,user_id,interested_uid,interested,date_modified
from app_meetme_t0_p0 union all
select 't1' tbl,user_id,interested_uid,interested,date_modified
from app_meetme_t1_p0 union all
select 't2' tbl,user_id,interested_uid,interested,date_modified
from app_meetme_t2_p0 union all
select 't3' tbl,user_id,interested_uid,interested,date_modified
from app_meetme_t3_p0 union all
select 't4' tbl,user_id,interested_uid,interested,date_modified
from app_meetme_t4_p0 union all
select 'mtc' tbl,user_id,interested_uid,interested,date_modified
from app_meetme_matches_p0;
