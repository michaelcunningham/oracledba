DROP TABLE SYSTEM.TOAD_PLAN_TABLE CASCADE CONSTRAINTS;

--
-- TOAD_PLAN_TABLE  (Table) 
--
CREATE TABLE SYSTEM.TOAD_PLAN_TABLE
(
  STATEMENT_ID     VARCHAR2(32 BYTE)                NULL,
  TIMESTAMP        DATE                             NULL,
  REMARKS          VARCHAR2(80 BYTE)                NULL,
  OPERATION        VARCHAR2(30 BYTE)                NULL,
  OPTIONS          VARCHAR2(30 BYTE)                NULL,
  OBJECT_NODE      VARCHAR2(128 BYTE)               NULL,
  OBJECT_OWNER     VARCHAR2(30 BYTE)                NULL,
  OBJECT_NAME      VARCHAR2(30 BYTE)                NULL,
  OBJECT_INSTANCE  NUMBER                           NULL,
  OBJECT_TYPE      VARCHAR2(30 BYTE)                NULL,
  SEARCH_COLUMNS   NUMBER                           NULL,
  ID               NUMBER                           NULL,
  COST             NUMBER                           NULL,
  PARENT_ID        NUMBER                           NULL,
  POSITION         NUMBER                           NULL,
  CARDINALITY      NUMBER                           NULL,
  OPTIMIZER        VARCHAR2(255 BYTE)               NULL,
  BYTES            NUMBER                           NULL,
  OTHER_TAG        VARCHAR2(255 BYTE)               NULL,
  PARTITION_ID     NUMBER                           NULL,
  PARTITION_START  VARCHAR2(255 BYTE)               NULL,
  PARTITION_STOP   VARCHAR2(255 BYTE)               NULL,
  DISTRIBUTION     VARCHAR2(30 BYTE)                NULL,
  OTHER            LONG                             NULL
);

--
-- TPTBL_IDX  (Index) 
--
CREATE INDEX TPTBL_IDX ON SYSTEM.TOAD_PLAN_TABLE(STATEMENT_ID);

DROP PUBLIC SYNONYM TOAD_PLAN_TABLE;

--
-- TOAD_PLAN_TABLE  (Synonym) 
--
CREATE PUBLIC SYNONYM TOAD_PLAN_TABLE FOR SYSTEM.TOAD_PLAN_TABLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON SYSTEM.TOAD_PLAN_TABLE TO PUBLIC;

