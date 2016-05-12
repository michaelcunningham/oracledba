SQL> SELECT rollback_sql_stmt
  2  FROM DB_SCHEMA_OBJ_TO_DROP
  3  WHERE renamed_obj_name IN
  4    (SELECT object_name
  5    FROM dba_objects
  6    WHERE object_type NOT IN ('TRIGGER','INDEX PARTITION','TABLE PARTITION')
  7    AND object_name LIKE 'D\_%' ESCAPE '\'
  8    )
  9  
SQL> /

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
rename D_1_UNT_NOTIFICATIONS_P32_SEQ to ACCOUNT_NOTIFICATIONS_P32_SEQ;          
rename D_86_CAFE_USER_FOOD_P37_SEQ to APPS_CAFE_USER_FOOD_P37_SEQ;              
rename D_97_CAFE_WAITER_CTRCT_P32_SEQ to APPS_CAFE_WAITER_CTRCT_P32_SEQ;        
rename D_20_CAFE_WAITER_TIPS_P38_SEQ to APPS_CAFE_WAITER_TIPS_P38_SEQ;          
rename D_31_APPS_CHAT_CONV_P33_SEQ to APPS_CHAT_CONV_P33_SEQ;                   
rename D_53_CHAT_MESSAGES_P39_SEQ to APPS_CHAT_MESSAGES_P39_SEQ;                
rename D_40_APPS_CAFE_AVATAR_P39_SEQ to APPS_CAFE_AVATAR_P39_SEQ;               
rename D_51_CAFE_FASHION_SET_P34_SEQ to APPS_CAFE_FASHION_SET_P34_SEQ;          
rename D_29_CONVERSATION_P37_SEQ to CONVERSATION_P37_SEQ;                       
rename D_40_RSATION_POSTS_P32_SEQ to CONVERSATION_POSTS_P32_SEQ;                
rename D_62_BED_SNAP_QUEUE_P38_SEQ to CR_EMBED_SNAP_QUEUE_P38_SEQ;              

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
rename D_95_B_PENDING_CID_ID_SEQ_P39 to CT_EMB_PENDING_CID_ID_SEQ_P39;          
rename D_7_MG_PENDING_CID_ID_SEQ_P34 to CT_IMG_PENDING_CID_ID_SEQ_P34;          
rename D_81_APPS_GAMES_GOAL_P35_SEQ to APPS_GAMES_GOAL_P35_SEQ;                 
rename D_15_PETS_ACHIEVEMENTS_P36_SEQ to APPS_PETS_ACHIEVEMENTS_P36_SEQ;        
rename D_37_APPS_TAGS_P34_SEQ to APPS_TAGS_P34_SEQ;                             
rename D_98_EED_MEDIA_ITEM_P32_SEQ to NEWSFEED_MEDIA_ITEM_P32_SEQ;              
rename D_66_FR_VOTES_RECEIVED_P37_SEQ to FR_VOTES_RECEIVED_P37_SEQ;             
rename D_19_Q_INDEX_BROWSE_P34_SEQ to Q_INDEX_BROWSE_P34_SEQ;                   
rename D_63_SEX_OFFENDERS_P38_SEQ to SEX_OFFENDERS_P38_SEQ;                     
rename D_96_TOPICS_POST_P39_SEQ to TOPICS_POST_P39_SEQ;                         
rename D_8_TOPICS_TOPIC_P34_SEQ to TOPICS_TOPIC_P34_SEQ;                        

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
rename D_68_ED_PENDING_CID_ID_SEQ_P37 to O_EMBED_PENDING_CID_ID_SEQ_P37;        
rename D_13_POLLS_P33_SEQ to POLLS_P33_SEQ;                                     
rename D_35_QUESTIONS_P39_SEQ to QUESTIONS_P39_SEQ;                             
rename D_46__EMAIL_DIGEST_P34_SEQ to QUEUE_EMAIL_DIGEST_P34_SEQ;                
rename D_79__IM_NOTIFICATION_P35_SEQ to QUEUE_IM_NOTIFICATION_P35_SEQ;          
rename D_2_CT_PHOTO_REMINDER_P33_SEQ to Q_ACCT_PHOTO_REMINDER_P33_SEQ;          
rename D_12_TOPICS_TOPIC_P38_SEQ to TOPICS_TOPIC_P38_SEQ;                       
rename D_31_USER_SHARES_P36_SEQ to USER_SHARES_P36_SEQ;                         
rename D_64_STICKER_PACKS_P37_SEQ to USER_STICKER_PACKS_P37_SEQ;                
ALTER TABLE D_62_CR_SIGN_AND_CIDS_P34_0919 RENAME TO CR_SIGN_AND_CIDS_P34_0919; 
ALTER TABLE D_7_E_REVIEW_QUEUE_P37_DUPS RENAME TO IMAGE_REVIEW_QUEUE_P37_DUPS;  

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
ALTER TABLE D_47_IMAGE_P34_IN RENAME TO IMAGE_P34_IN;                           
ALTER TABLE D_58_IMAGE_P38_DL RENAME TO IMAGE_P38_DL;                           
ALTER TABLE D_77_PAGE_VIEW_COUNTS_P35_IN RENAME TO PAGE_VIEW_COUNTS_P35_IN;     
ALTER TABLE D_88_PAGE_VIEW_COUNTS_P39_DL RENAME TO PAGE_VIEW_COUNTS_P39_DL;     
ALTER TABLE D_72_USER_STATUS_P34_DL RENAME TO USER_STATUS_P34_DL;               
ALTER TABLE D_83_USER_STATUS_P37_UP RENAME TO USER_STATUS_P37_UP;               
rename D_65_EUE_HI5FLAGGED_P35_VIEW to CR_QUEUE_HI5FLAGGED_P35_VIEW;            
rename D_32_ATION_SENT_T1_P35_VIEW to INVITATION_SENT_T1_P35_VIEW;              
rename D_61_OMMENTS_LIKES_T2_P38_VIEW to NFP_COMMENTS_LIKES_T2_P38_VIEW;        
rename D_72_NFP_EVENTS_T0_P33_VIEW to NFP_EVENTS_T0_P33_VIEW;                   
rename D_4_USER_VISITS_T2_P38_VIEW to NFP_USER_VISITS_T2_P38_VIEW;              

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
rename D_26__COMMENT_RET_P36_VIEW to PHOTO_COMMENT_RET_P36_VIEW;                
rename D_59__EMAIL_DIGEST_T0_P37_VIEW to QUEUE_EMAIL_DIGEST_T0_P37_VIEW;        
rename D_70__EMAIL_DIGEST_T1_P32_VIEW to QUEUE_EMAIL_DIGEST_T1_P32_VIEW;        
rename D_92__EMAIL_DIGEST_T2_P38_VIEW to QUEUE_EMAIL_DIGEST_T2_P38_VIEW;        
rename D_4_TESTIMONIAL_P33_VIEW to TESTIMONIAL_P33_VIEW;                        
rename D_26_TESTIMONIAL_RET_P39_VIEW to TESTIMONIAL_RET_P39_VIEW;               
rename D_48_USER_MESSAGES_P37_VIEW to USER_MESSAGES_P37_VIEW;                   
rename D_70_MESSAGES_T201008_P35_VIEW to USER_MESSAGES_T201008_P35_VIEW;        
rename D_4__MESSAGES_T201010_P36_VIEW to USER_MESSAGES_T201010_P36_VIEW;        
rename D_37_MESSAGES_T201012_P37_VIEW to USER_MESSAGES_T201012_P37_VIEW;        
rename D_48_MESSAGES_T201204_P32_VIEW to USER_MESSAGES_T201204_P32_VIEW;        

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
rename D_70_MESSAGES_T201205_P38_VIEW to USER_MESSAGES_T201205_P38_VIEW;        
rename D_81_MESSAGES_T201206_P33_VIEW to USER_MESSAGES_T201206_P33_VIEW;        
rename D_4__MESSAGES_T201207_P39_VIEW to USER_MESSAGES_T201207_P39_VIEW;        
rename D_15_MESSAGES_T201208_P34_VIEW to USER_MESSAGES_T201208_P34_VIEW;        
rename D_48_MESSAGES_T201210_P35_VIEW to USER_MESSAGES_T201210_P35_VIEW;        
rename D_70_US_MSS_P33_VIEW to US_MSS_P33_VIEW;                                 
rename D_23_CHAT_MESSAGES_T0_P35_VIEW to APPS_CHAT_MESSAGES_T0_P35_VIEW;        
rename D_83_EUE_HI5PHOTO_P37_VIEW to CR_QUEUE_HI5PHOTO_P37_VIEW;                
rename D_94_CR_QUEUE_PHOTO_P32_VIEW to CR_QUEUE_PHOTO_P32_VIEW;                 
rename D_50_ATION_SENT_T2_P37_VIEW to INVITATION_SENT_T2_P37_VIEW;              
rename D_61_INVSENT_EMAIL_T0_P32_VIEW to INVSENT_EMAIL_T0_P32_VIEW;             

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
rename D_90_NFP_EVENTS_T1_P35_VIEW to NFP_EVENTS_T1_P35_VIEW;                   
rename D_36_CHAT_MESSAGES_T1_P32_VIEW to APPS_CHAT_MESSAGES_T1_P32_VIEW;        
rename D_58_CHAT_MESSAGES_T2_P38_VIEW to APPS_CHAT_MESSAGES_T2_P38_VIEW;        
rename D_33_VIEW_LOG_T201201_P38_VIEW to CR_REVIEW_LOG_T201201_P38_VIEW;        
rename D_67_INVSENT_EMAIL_T0_P38_VIEW to INVSENT_EMAIL_T0_P38_VIEW;             
rename D_78_INVSENT_EMAIL_T1_P33_VIEW to INVSENT_EMAIL_T1_P33_VIEW;             
rename D_22_VENT_COMMENTS_T0_P34_VIEW to NFP_EVENT_COMMENTS_T0_P34_VIEW;        
rename D_54_S_INVITED_T0_P35_VIEW to EMAILS_INVITED_T0_P35_VIEW;                
rename D_98_INVSENT_EMAIL_T2_P37_VIEW to INVSENT_EMAIL_T2_P37_VIEW;             
rename D_10_INV_RECEIVED_T0_P32_VIEW to INV_RECEIVED_T0_P32_VIEW;               
rename D_72_VENT_LIKES_T0_P36_VIEW to NFP_EVENT_LIKES_T0_P36_VIEW;              

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
rename D_6__CHAT_MESSAGES_T5_P37_VIEW to APPS_CHAT_MESSAGES_T5_P37_VIEW;        
rename D_17_APP_MEETME_T0_P32_VIEW to APP_MEETME_T0_P32_VIEW;                   
rename D_84_S_INVITED_T2_P33_VIEW to EMAILS_INVITED_T2_P33_VIEW;                
rename D_29_INV_RECEIVED_T1_P35_VIEW to INV_RECEIVED_T1_P35_VIEW;               
rename D_89_VENT_LIKES_T1_P37_VIEW to NFP_EVENT_LIKES_T1_P37_VIEW;              
rename D_1_EVENT_LIKES_T2_P32_VIEW to NFP_EVENT_LIKES_T2_P32_VIEW;              
rename D_21_APP_MEETME_T0_P36_VIEW to APP_MEETME_T0_P36_VIEW;                   
rename D_22__DIGEST_DATA_T0_P38_VIEW to EMAIL_DIGEST_DATA_T0_P38_VIEW;          
rename D_33__DIGEST_DATA_T1_P33_VIEW to EMAIL_DIGEST_DATA_T1_P33_VIEW;          
rename D_68_ATCHES_STGPRT03_P19_VIEW to JMK_MATCHES_STGPRT03_P19_VIEW;          
rename D_79_ATCHES_STGPRT03_P29_VIEW to JMK_MATCHES_STGPRT03_P29_VIEW;          

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
rename D_90_ATCHES_STGPRT03_P39_VIEW to JMK_MATCHES_STGPRT03_P39_VIEW;          
rename D_19_SER_EVENTS_T0_P34_VIEW to NFP_USER_EVENTS_T0_P34_VIEW;              
rename D_39__DIGEST_DATA_T1_P39_VIEW to EMAIL_DIGEST_DATA_T1_P39_VIEW;          
rename D_50__DIGEST_DATA_T2_P34_VIEW to EMAIL_DIGEST_DATA_T2_P34_VIEW;          
rename D_8_MATCHES_STGPRT03_P54_VIEW to JMK_MATCHES_STGPRT03_P54_VIEW;          
rename D_19_ATCHES_STGPRT03_P6_VIEW to JMK_MATCHES_STGPRT03_P6_VIEW;            
rename D_70_SER_VISITS_T0_P37_VIEW to NFP_USER_VISITS_T0_P37_VIEW;              
rename D_15_CR_QUEUE_CONSULT_P33_VIEW to CR_QUEUE_CONSULT_P33_VIEW;             
rename D_99_INVITATIONS_T2_P35_VIEW to INVITATIONS_T2_P35_VIEW;                 
rename D_43_OMMENTS_LIKES_T1_P36_VIEW to NFP_COMMENTS_LIKES_T1_P36_VIEW;        
rename D_85_SER_VISITS_T1_P36_VIEW to NFP_USER_VISITS_T1_P36_VIEW;              

ROLLBACK_SQL_STMT                                                               
--------------------------------------------------------------------------------
rename D_21_CR_QUEUE_CONSULT_P39_VIEW to CR_QUEUE_CONSULT_P39_VIEW;             
rename D_32_CR_QUEUE_FLAGGED_P34_VIEW to CR_QUEUE_FLAGGED_P34_VIEW;             

101 rows selected.

SQL> spool off
