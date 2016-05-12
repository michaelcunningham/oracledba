CREATE SEQUENCE TAG.TOPIC_ID_SEQ
  START WITH 400
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 100
  NOORDER
  NOKEEP
  GLOBAL
/

CREATE TABLE TAG.S_PAGE_VIEW_LOG
(
  DT       DATE                                 NOT NULL,
  USER_ID  NUMBER(15)                           NOT NULL
)
NOCOMPRESS 
TABLESPACE datatbs1  
PARTITION BY RANGE (DT)
INTERVAL( NUMTODSINTERVAL (1, 'DAY'))
(  
  PARTITION P_04062015 VALUES LESS THAN (TIMESTAMP' 2015-04-07 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE datatbs1
)
/

CREATE INDEX tag.S_PAGE_VIEW_LOG_IDX1 ON tag.S_PAGE_VIEW_LOG (DT) tablespace datatbs1 LOCAL
/

CREATE TABLE tag.S_LOGIN_LOG
(
  DT       DATE                                 NOT NULL,
  USER_ID  NUMBER(15)                           NOT NULL,
  STATUS   VARCHAR2(30 BYTE)
)
TABLESPACE datatbs1
PARTITION BY RANGE (DT)
INTERVAL( NUMTODSINTERVAL (1, 'DAY'))
(  
  PARTITION P_04062015 VALUES LESS THAN (TIMESTAMP' 2015-04-07 00:00:00')
    LOGGING
    NOCOMPRESS 
    TABLESPACE datatbs1
)
/

CREATE INDEX tag.S_LOGIN_LOG_IDX1 ON tag.S_LOGIN_LOG (DT) tablespace datatbs1 LOCAL
/

CREATE TABLE TAG.TOPIC_CONTROL
(
  TOPIC_ID                NUMBER(15)            NOT NULL,
  TOPIC_NAME              VARCHAR2(100 BYTE),
  TOPIC_PARTITIONS        VARCHAR2(2000 BYTE),
  PARTITION_RETENTION     NUMBER(5)             DEFAULT 90                    NOT NULL,
  IS_RUNNING              VARCHAR2(1 BYTE)      DEFAULT 'Y'                   NOT NULL,
  SHOULD_ALERT            NUMBER(1)             DEFAULT 1                     NOT NULL,
  LAST_TIME_RCVD_WARNING  NUMBER(10)            DEFAULT 7200000               NOT NULL,
  LAST_TIME_RCVD_ERROR    NUMBER(10)            DEFAULT 14400000              NOT NULL,
  MSG_TIME_WARNING        NUMBER(10)            DEFAULT 1800000               NOT NULL,
  MSG_TIME_ERROR          NUMBER(10)            DEFAULT 3600000               NOT NULL,
  DATE_ADDED              DATE                  DEFAULT SYSDATE               NOT NULL,
  LAST_TIME_UPDATED       TIMESTAMP(9) WITH LOCAL TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
  constraint TOPIC_CONTROL_pk PRIMARY KEY(topic_id) using index tablespace datatbs1
)
TABLESPACE datatbs1
/

CREATE TABLE TAG.TASK_PROGRESS
(
  TOPIC_ID        NUMBER(15),
  PARTITION_NUM   NUMBER(15),
  CURRENT_OFFSET  NUMBER(15)                    NOT NULL,
  DATE_ADDED      DATE                          DEFAULT SYSDATE               NOT NULL,
  DATE_UPDATED    DATE                          DEFAULT SYSDATE               NOT NULL,
  constraint topic_progress_pk PRIMARY KEY(topic_id, partition_num) using index tablespace datatbs1
)
TABLESPACE datatbs1
/

CREATE OR REPLACE PACKAGE TAG.EtlMngmt as
    PROCEDURE UPDATE_TOPIC_PARTITION(
          inTopicID       IN NUMBER,
          inPartitionList IN VARCHAR2,
          outStatus       OUT NUMBER,
          outErrMsg       OUT VARCHAR2
    );

    PROCEDURE ADD_PARTITION(
          inTopicID      IN NUMBER,
          inPartitionNum IN NUMBER
    );

    PROCEDURE COMMIT_OFFSET(
          inTopicId      IN NUMBER,
          inPartition    IN NUMBER,
          inOffset       IN NUMBER,
          outStatus     OUT VARCHAR2,
          outErrMsg     OUT VARCHAR2
    );

    PROCEDURE STOP_ALL_ETL;
    
    PROCEDURE START_ALL_ETL;
END;
/

CREATE OR REPLACE PACKAGE BODY TAG.EtlMngmt as
    PROCEDURE UPDATE_TOPIC_PARTITION(
          inTopicID       IN NUMBER,
          inPartitionList IN VARCHAR2,
          outStatus       OUT NUMBER,
          outErrMsg       OUT VARCHAR2
    ) AS
        l_array dbms_utility.lname_array;
        l_count binary_integer;
    BEGIN
        outStatus := 0;
        outErrMsg := '';
        dbms_utility.comma_to_table ( list   => regexp_replace(inPartitionList,'(^|,)','\1x'), 
                                      tablen => l_count,
                                      tab    => l_array );
        FOR i in 1..l_count
        LOOP
            ADD_PARTITION(inTopicID,to_number(substr(l_array(i),2)));
        END LOOP;
        
        UPDATE TOPIC_CONTROL 
        SET TOPIC_PARTITIONS = inPartitionList, 
            LAST_TIME_UPDATED = SYSTIMESTAMP
        WHERE TOPIC_ID = inTopicID;
        COMMIT;
    EXCEPTION 
        WHEN OTHERS THEN
            outStatus := SQLCODE;
            outErrMsg := SUBSTR(SQLERRM, 1, 200);
            ROLLBACK;         
    END;
    
    PROCEDURE ADD_PARTITION(
          inTopicID      IN NUMBER,
          inPartitionNum IN NUMBER
         ) AS
        mPartition NUMBER(15,0);
    BEGIN
        SELECT PARTITION_NUM
        INTO mPartition
        FROM task_progress
        where topic_id = inTopicID and partition_num = inPartitionNum;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO task_progress(TOPIC_ID, PARTITION_NUM, CURRENT_OFFSET) 
            VALUES (inTopicID, inPartitionNum, 0); 
    END;

    PROCEDURE COMMIT_OFFSET(
          inTopicId      IN NUMBER,
          inPartition    IN NUMBER,
          inOffset       IN NUMBER,
          outStatus     OUT VARCHAR2,
          outErrMsg     OUT VARCHAR2
    ) AS
      mOffset NUMBER(15,0);
    BEGIN
       outStatus := 0;
       outErrMsg := '';
       /*SELECT CURRENT_OFFSET 
       INTO mOffset
       FROM TOPIC_PROGRESS
       WHERE 
          TOPIC_ID = inTopicId AND PARTITION_NUM = inPartition
       FOR UPDATE;-- OF CURRENT_OFFSET;*/
                 
       UPDATE  task_progress
       SET CURRENT_OFFSET = inOffset,
           DATE_UPDATED = SYSDATE
       WHERE 
           TOPIC_ID = inTopicId AND PARTITION_NUM = inPartition;

    EXCEPTION
        WHEN OTHERS THEN
           outStatus := SQLCODE;
           outErrMsg := SUBSTR(SQLERRM, 1, 1200); 
    END; 
    
    PROCEDURE STOP_ALL_ETL AS
    BEGIN
        update TOPIC_CONTROL set is_running = 'N', LAST_TIME_UPDATED = SYSTIMESTAMP;
    EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
    
    PROCEDURE START_ALL_ETL AS
    BEGIN
        update TOPIC_CONTROL set is_running = 'Y', LAST_TIME_UPDATED = SYSTIMESTAMP;
    EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
END;
/



--------------------------------------------------------
--  DDL for Table DAILY_ACTIVE_USERS
--------------------------------------------------------

  CREATE TABLE "TAG"."DAILY_ACTIVE_USERS" 
   (	"DT" DATE, 
	"USER_ID" NUMBER(15,0), 
	"ACTIVE_DAYS" NUMBER(*,0)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
  STORAGE(
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE DATATBS1 
  PARTITION BY RANGE ("DT") INTERVAL (NUMTODSINTERVAL(1,'DAY')) 
 (PARTITION "NO_PART"  VALUES LESS THAN (TO_DATE(' 2007-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING 
  STORAGE(
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE DATATBS1 ) ;
/
--------------------------------------------------------
--  DDL for Index DAILY_ACTIVE_USERS_IX1
--------------------------------------------------------

  CREATE INDEX "TAG"."DAILY_ACTIVE_USERS_IX1" ON "TAG"."DAILY_ACTIVE_USERS" ("USER_ID", "DT") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE  DATATBS1  LOCAL
 (PARTITION "NO_PART" 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 LOGGING 
  STORAGE(
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE DATATBS1 ) ;
/
