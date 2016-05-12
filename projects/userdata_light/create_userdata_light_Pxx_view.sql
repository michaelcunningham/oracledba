CREATE OR REPLACE FORCE VIEW USERDATA_VIEW_Pxx
(USER_ID, FIRST_NAME, LAST_NAME, FICTITIOUS_USER_ID, CANCEL_REASON_CODE, 
 GENDER, BIRTHDATE, LOCALE, APPS_OPTOUT_SETTINGS_1, LAST_LOGIN_DATE, 
 REG_SOURCE, ETHNICITY, RELIGION, SEXUAL_PREFERENCE, DISPLAYNAME, 
 DISPLAYNAME_N, TYPE, FIRST_NAME_N, LAST_NAME_N, HI5_FINISHED_WIZARD_DATE, 
 PRIMARY_PHOTO_ID, PHOTO_URL, DATING, FRIENDS, SERRELATIONSHIP, 
 NETWORKING, RELATIONSHIP, INFERRED_ETHNICITY, TIMEZONE_INT_ID, HIDE_ONLINE_STATUS, 
 SEARCH_PREFS)
BEQUEATH DEFINER
AS 
SELECT ud.user_id,
      first_name,
      last_name,
      fictitious_user_id,
      cancel_reason_code,
      gender,
      birthdate,
      locale,
      apps_optout_settings_1,
      us.last_login_date,
      REG_SOURCE,
      ethnicity,
      religion,
      sexual_preference,
      displayname,
      displayname_n,
      TYPE,
      first_name_n,
      last_name_n,
      us.hi5_finished_wizard_date,
      primary_photo_id,
      NULL,
      dating,
      friends,
      serrelationship,
      networking,
      relationship,
      inferred_ethnicity,
      timezone_int_id,
      hide_online_status,
      nvl(search_prefs_n,search_prefs) as search_prefs
     FROM    userdata_pxx ud
      LEFT OUTER JOIN
         user_stats_pxx us
      ON ud.user_id = us.user_id;

