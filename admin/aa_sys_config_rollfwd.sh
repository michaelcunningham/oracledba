#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/${ORACLE_SID}_aa_sys_config_rollfwd_$log_date.log

. /dba/admin/dba.lib

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=`get_tns_from_orasid $ORACLE_SID`
novausername=novaprd
novauserpwd=`get_user_pwd $tns $novausername`

sqlplus -s << EOF >> $log_file
$novausername/$novauserpwd
set head off
prompt Running .............................. aa_sys_config_rollfwd

declare
	p_return_id number;
	p_current_date date;
begin
	select	pol_admin_acct_date
	into	p_current_date
	from	aa_sys_config;

	if trunc( p_current_date ) != trunc(sysdate) then
		util_pkg.mv_syscnfg_admin_acct_dt_frwrd( p_return_id );
		util_pkg.mv_syscnfg_eod_acct_dt_frwrd( p_return_id );
	end if;
end;
/

exit;
EOF
