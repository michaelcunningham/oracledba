#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID>"
  echo
  echo "	Example : $0 tdccpy"
  echo
  exit
fi

export ORACLE_SID=$1

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/scramble_ssn_$log_date.log

if [ "`grep ^${ORACLE_SID} /dba/admin/oraid_user`" = "" ]
then
  echo Invalid ORACLE_SID ${ORACLE_SID}
  echo The ORACLE_SID is not listed in the oraid_user file.
  exit
fi

. /dba/admin/dba.lib
tns=`get_tns_from_orasid $ORACLE_SID`
novausername=novaprd
novauserpwd=`get_user_pwd $tns $novausername`

sqlplus -s /nolog << EOF > $log_file

connect $novausername/$novauserpwd
alter table cm_contact disable all triggers;
alter table ni_edi_cms disable all triggers;
update	cm_contact
set	ssn_num = translate( ssn_num, '0123456789', '1234567890' )
where	ssn_num is not null;

update	ni_edi_cms
set	ssn_num = translate( ssn_num, '0123456789', '1234567890' )
where	ssn_num is not null;
commit;

alter table cm_contact enable all triggers;
alter table ni_edi_cms enable all triggers;

exit;
EOF

