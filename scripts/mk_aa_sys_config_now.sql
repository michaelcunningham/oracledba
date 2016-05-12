update	aa_sys_config
set	pol_admin_acct_date = trunc(sysdate),
	eod_acct_date = trunc(sysdate);

commit;

