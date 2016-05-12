begin
UPDATE aa_sys_config a
   SET a.pol_admin_acct_date = TRUNC (SYSDATE),
       a.eod_acct_date = TRUNC (SYSDATE);
commit;
end;
/
