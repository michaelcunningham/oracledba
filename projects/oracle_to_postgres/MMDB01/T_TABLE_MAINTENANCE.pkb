CREATE OR REPLACE PACKAGE BODY TAG.T_TABLE_MAINTENANCE is

PROCEDURE check_t_tables(intable                    IN       varchar2,
                                         inPkey                    IN        NUMBER,
                                         inRotationTime        IN       NUMBER,
                                         inTotalTTables        IN       NUMBER,
                                         inWaitPeriodTime    IN       NUMBER DEFAULT 0) as
    ssql varchar2(1000);
    err_msg varchar2(600);
     min_partition number(2);
    max_partition number(2);
    retTVal          number(1);
     tTable           varchar2(35);
    final_count number:=0;
    sample_partition number(2);
    status number := 1;
    dbname varchar2(35);
  BEGIN

     select sys_context('userenv','instance_name')
     into dbname
     from dual;

     retTVal := get_next_t_table(inRotationTime,inWaitPeriodTime,inTotalTTables );
     DBMS_OUTPUT.PUT_LINE('Next ttable to be used: ' || retTVal);
      IF retTVal >= 0
      THEN

            BEGIN
                        tTable := intable || '' || retTVal || '_P'  || inPkey;
                         /*** Truncate T Table ***/
                         ssql:='select count(*) from '||tTable || '';
                         execute immediate ssql into final_count;
                         DBMS_OUTPUT.PUT_LINE( 'SQL statement:  ssql=' || ssql);
                         IF final_count != 0
                         THEN
                            DBMS_OUTPUT.PUT_LINE( 'Failed to truncate! SQL statement:  ssql=' || ssql);
                            DBMS_OUTPUT.PUT_LINE( 'Count is not zero');
                            status := 0;
                        END IF;
            EXCEPTION
            WHEN OTHERS THEN
                        err_msg := 'T: ' || tTable || ' E: ' || SUBSTR(SQLERRM, 1, 200);
                        DBMS_OUTPUT.PUT_LINE( err_msg);
                        NULL;
            END;

             IF status = 1
             THEN
                   DBMS_OUTPUT.PUT_LINE( 'truncated ' || intable || ' in  '  || dbname  || ' successfuly ');
             ELSE
                   DBMS_OUTPUT.PUT_LINE( 'truncated ' || intable || ' in  ' || dbname  || ' unsuccessfuly ');
             END IF;
     END IF;
     DBMS_OUTPUT.PUT_LINE('******************** FINISHED Checking truncate status for table ' || intable || ' ************************************');
 end check_t_tables;

PROCEDURE truncate_t_tables(intable                   IN varchar2,
                                            inPkey                    IN        NUMBER,
                                            inRotationTime        IN       NUMBER,
                                            inTotalTTables        IN      NUMBER,
                                            inWaitPeriodTime    IN       NUMBER  DEFAULT 0)
AS
    min_partition number(2);
    max_partition number(2);
    retTVal          number(1);
    tTable           varchar2(35);
    ssql               varchar2(600);
BEGIN

     retTVal :=  get_next_t_table(inRotationTime,inWaitPeriodTime,inTotalTTables );
     DBMS_OUTPUT.PUT_LINE('Next ttable to be used: ' || retTVal);
     IF retTVal >= 0
     THEN
             tTable := intable || '' || retTVal || '_P';

             BEGIN
                 /*** Truncate T Table ***/
                 ssql:='truncate table '|| tTable || '' || inPkey;
                 DBMS_OUTPUT.PUT_LINE('SQL: ' || ssql);
                 execute immediate ssql;
                 DBMS_OUTPUT.PUT_LINE( 'SQL statement:  ssql=' || ssql);
             EXCEPTION
                  WHEN OTHERS THEN
                   DBMS_OUTPUT.PUT_LINE('T: ' || tTable || ' E: ' || SUBSTR(SQLERRM, 1, 200) );
                  NULL;
             END;

     END IF;
END;

FUNCTION    get_next_t_table(
                                   inRotationTime        IN       NUMBER,
                                   inWaitPeriodTime    IN       NUMBER,
                                   inTotalTTables        IN      NUMBER) RETURN NUMBER IS
    mUnixTime NUMBER;
    mTUnixTime NUMBER;
    mIndex      NUMBER;
    mOldIndex NUMBER;
    mNextIndex      NUMBER;
BEGIN

    DBMS_OUTPUT.PUT_LINE('******************************************************');

         SELECT DATE_UNIX_TS(0)
         INTO mUnixTime
         FROM DUAL;

        DBMS_OUTPUT.PUT_LINE('Current UTS: ' || mUnixTime);

        SELECT trunc(mod(trunc(mUnixTime / inRotationTime), inTotalTTables))
        INTO mIndex
        FROM dual;

        DBMS_OUTPUT.PUT_LINE('Current TTable: ' || mIndex);

        SELECT mod((mIndex + 1), inTotalTTables)
        INTO mOldIndex
        FROM DUAL;

        DBMS_OUTPUT.PUT_LINE('Old TTable: ' || mOldIndex);

       -- mWaitPeriodTime := 30;

        SELECT DATE_UNIX_TS(inWaitPeriodTime)
        INTO mTUnixTime
        FROM DUAL;


        SELECT trunc(mod(trunc(mTUnixTime / inRotationTime), inTotalTTables))
        INTO mNextIndex
        FROM dual;

        DBMS_OUTPUT.PUT_LINE('Next TTable: ' || mNextIndex);

        IF mOldIndex = mNextIndex
        THEN
              RETURN -1;
        END IF;
        DBMS_OUTPUT.PUT_LINE('==============================================');
        RETURN mOldIndex;
END;

FUNCTION DATE_UNIX_TS (inDays         IN    NUMBER)
   RETURN NUMBER
IS
   ts   NUMBER;
BEGIN
   SELECT trunc((((SYSDATE  + inDays) - TO_DATE('01-01-1970 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) * 24 * 60 * 60) -
           TO_NUMBER(SUBSTR(TZ_OFFSET(sessiontimezone),1,3))*3600) as dt
   INTO ts
   FROM DUAL;
   RETURN ts;
END date_unix_ts;

END;
/