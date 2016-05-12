DECLARE
    TYPE ref_type_cur IS REF CURSOR;
    topicControlCur ref_type_cur;
    mTopicName VARCHAR2(35);
    mTableName VARCHAR2(35);
    mDaysToRetainPartition number(5);
    mOldestPartitionToKeepDate DATE;
    mEarlistPartitionDate DATE:= TO_DATE('2000-02-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
    mPartitionToDropDate DATE;
    mSql     varchar2(2000);
    sSql     varchar2(2000);
BEGIN
    mSql := 'select topic_name, table_name, partition_retention 
             from topic_control 
             where table_name is not null and partition_retention > 0';
    OPEN topicControlCur FOR mSql;
    LOOP
        DBMS_OUTPUT.PUT('==== ' || TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS') || 
                             ' Starting drop partition script ====');
        DBMS_OUTPUT.NEW_LINE;
        FETCH topicControlCur INTO mTopicName, mTableName, mDaysToRetainPartition;
        EXIT WHEN topicControlCur%NOTFOUND;
        mOldestPartitionToKeepDate := to_date(to_char((sysdate - (mDaysToRetainPartition + 1 )),'MM/DD/YYYY') || ' 00:00:00', 'MM/DD/YYYY HH24:MI:SS');
        DBMS_OUTPUT.PUT_LINE('==== Starting. Topic(' || mTopicName || 
                             ') Table (' ||  mTableName || ') Retention (' || 
                             mDaysToRetainPartition || ') OldestPartitionToKeepDate (' ||
                             TO_CHAR(mOldestPartitionToKeepDate,'MM-DD-YYYY HH24:MI:SS') || 
                             ') ==== ');
        
        for r in(
                 select  table_name, partition_name, high_value
                 from    user_tab_partitions
                 where   table_name = upper(mTableName)
                 and     partition_position <> (
                                select  max( partition_position )
                                from    user_tab_partitions
                                where   table_name = upper(mTableName) )
                )
         LOOP
            execute immediate 'select ' || r.high_value || ' from dual ' into mPartitionToDropDate;
            DBMS_OUTPUT.PUT_LINE('CheckingPartition(' || r.partition_name || ') HighValue('||  
                                  TO_CHAR(mPartitionToDropDate,'MM-DD-YYYY HH24:MI:SS') || 
                                 ') OldestPartitionToKeepDate(' || mOldestPartitionToKeepDate || ')');
            IF( mPartitionToDropDate> mEarlistPartitionDate AND 
                mPartitionToDropDate < mOldestPartitionToKeepDate )
            THEN                
                DBMS_OUTPUT.PUT_LINE('DroppingPartition (' || r.partition_name || ') High Value('||  
                                      TO_CHAR(mPartitionToDropDate,'MM-DD-YYYY HH24:MI:SS') ||
                                 ') OldestPartitionToKeepDate(' || mOldestPartitionToKeepDate || ')');
                sSql := 'ALTER TABLE '||r.table_name||' DROP PARTITION '||r.partition_name;
                DBMS_OUTPUT.PUT_LINE(sSql);
                execute immediate sSql;
            ELSE
                DBMS_OUTPUT.PUT_LINE('KeepingPartition (' || r.partition_name || ') HighValue('||  
                                     TO_CHAR(mPartitionToDropDate,'MM-DD-YYYY HH24:MI:SS') ||
                                 ') OldestPartitionToKeepDate(' || mOldestPartitionToKeepDate || ')');
            END IF;
         END LOOP;
         DBMS_OUTPUT.PUT_LINE('==== Finished. Topic(' || mTopicName || 
                             ') Table (' ||  mTableName || ') ==== ');
    END LOOP;
    CLOSE topicControlCur;

    DBMS_OUTPUT.PUT_LINE('==== ' || TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS') || 
                             ' Finished dropping partitions ====');
END;
/
