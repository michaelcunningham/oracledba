set termout off
whenever sqlerror exit 1
declare
	n_db_backup_audit_id int;
begin
	select	db_backup_audit_id
	into	n_db_backup_audit_id
	from	db_backup_audit
	where	instance_name = '&1'
	and	snapshot_name = '&2'
	and	snapshot_timestamp > sysdate - &3/1440;
exception
	when no_data_found then
		raise;
end;
/
exit
