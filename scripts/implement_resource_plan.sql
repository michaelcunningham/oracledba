set echo on time on timing on
set heading on
set serveroutput on
spool implement_resource_plan.log

DECLARE     
begin
    sys.dbms_resource_manager.clear_pending_area();
    sys.dbms_resource_manager.create_pending_area();
    sys.dbms_resource_manager.create_consumer_group(CONSUMER_GROUP=>'CPU_QUERY_TIME_LIMIT_GRP',

    COMMENT=>'Consumer group for TAGREAD to limit parallelism,I/O and CPU Time');
    sys.dbms_resource_manager.set_consumer_group_mapping(attribute => DBMS_RESOURCE_MANAGER.ORACLE_USER,
                                                         value => 'TAGREAD',consumer_group =>'CPU_QUERY_TIME_LIMIT_GRP');

    -- Create resource plan:
    sys.dbms_resource_manager.create_plan(PLAN=> 'CPU_QUERY_TIME_LIMIT',COMMENT=>'Cancel Sql plan for TAGREAD');

    --Need to create plan_directive
    --Limiting parallelism to max 1, and CPU_time to 180 sec
    sys.dbms_resource_manager.create_plan_directive(
                                                        PLAN=> 'CPU_QUERY_TIME_LIMIT',
                                                        GROUP_OR_SUBPLAN=>'CPU_QUERY_TIME_LIMIT_GRP',
                                                        COMMENT=>'Kill statement after exceeding 180 sec , limit parallelism to max 1 ',
                                                        --Specifies a limit on the degree of parallelism for any operation.
                                                        PARALLEL_DEGREE_LIMIT_P1 => 1,
                                                        -- specifies the CPU percentage to allocate at the first level.
                                                        MGMT_P1 => 10,
                                                        SWITCH_GROUP=>'KILL_SESSION',
                                                        -- Specifies the time (in CPU seconds) that a call can execute before an action is taken. 
                                                        -- The action is specified by SWITCH_GROUP.
                                                        SWITCH_TIME=>180,
                                                        -- Specifies the maximum execution time (in CPU seconds) allowed for a call. If the optimizer estimates that a call will take longer than MAX_EST_EXEC_TIME, 
                                                        -- the call is not allowed to proceed and ORA-07455 is issued. If the optimizer does not provide an estimate, this directive has no effect.
                                                        MAX_EST_EXEC_TIME=>180
                                                   );

    --Its compulsory to specify directive for OTHER_GROUPS else this will fail
    dbms_resource_manager.create_plan_directive(PLAN=> 'CPU_QUERY_TIME_LIMIT',GROUP_OR_SUBPLAN=>'OTHER_GROUPS',CPU_P1=>90);
    sys.dbms_resource_manager.validate_pending_area;
    sys.dbms_resource_manager.submit_pending_area;
end;
/

--Grant TAGREAD USER to switch group
exec dbms_resource_manager_privs.grant_switch_consumer_group('TAGREAD','CPU_QUERY_TIME_LIMIT_GRP',false);
--Set initial group for RO_USER to CPU_QUERY_TIME_LIMIT_GRP 
exec dbms_resource_manager.set_initial_consumer_group('TAGREAD','CPU_QUERY_TIME_LIMIT_GRP');
ALTER SYSTEM SET RESOURCE_MANAGER_PLAN = CPU_QUERY_TIME_LIMIT
/

spool off

