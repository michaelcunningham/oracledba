CREATE OR REPLACE FORCE VIEW APP_MEETME_P0_VIEW
(TBL, USER_ID, INTERESTED_UID, INTERESTED, DATE_MODIFIED)
BEQUEATH DEFINER
AS 
SELECT 't0' tbl,
          user_id,
          interested_uid,
          interested,
          date_modified
     FROM app_meetme_t0_p0
   UNION ALL
   SELECT 't1' tbl,
          user_id,
          interested_uid,
          interested,
          date_modified
     FROM app_meetme_t1_p0
   UNION ALL
   SELECT 't2' tbl,
          user_id,
          interested_uid,
          interested,
          date_modified
     FROM app_meetme_t2_p0
   UNION ALL
   SELECT 't3' tbl,
          user_id,
          interested_uid,
          interested,
          date_modified
     FROM app_meetme_t3_p0
   UNION ALL
   SELECT 't4' tbl,
          user_id,
          interested_uid,
          interested,
          date_modified
     FROM app_meetme_t4_p0
   UNION ALL
   SELECT 't5' tbl,
          user_id,
          interested_uid,
          interested,
          date_modified
     FROM app_meetme_t5_p0
   UNION ALL
   SELECT 'mtc' tbl,
          user_id,
          interested_uid,
          interested,
          date_modified
     FROM app_meetme_matches_p0;

