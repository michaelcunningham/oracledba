-- Run in the NOVAPRD schema
-- Requested by Boris on 8/28/2008
update	tm_task
set	task_status_id = 'CL'
where	task_status_id in ('IP', 'NS')
and	bus_entity_type_id = 'V';
commit;
