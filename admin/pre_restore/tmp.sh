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
log_file=$log_dir/${ORACLE_SID}_security_save_process_$log_date.log

. /dba/admin/dba.lib

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=`get_tns_from_orasid $ORACLE_SID`
securityusername=security
securityuserpwd=`get_user_pwd $tns $securityusername`
securitysaveusername=security
securitysaveuserpwd=`get_user_pwd $tns $securityusername`

echo "securityusername     " $securityusername
echo "securityuserpwd      " $securityuserpwd
echo "securitysaveusername " $securitysaveusername
echo "securitysaveuserpwd  " $securitysaveuserpwd

sqlplus -s /nolog << EOF
connect / as sysdba
set serveroutput on

begin
        for r in (
                select  'alter system disconnect session '''
                        || sid || ',' || serial# || ''' immediate' sql_text
                from    v\$session
                where   username = 'SECURITY' )
        loop
                dbms_output.put_line( r.sql_text );
                execute immediate r.sql_text;
        end loop;
end;
/

drop user security cascade;


/dba/admin/pre_restore/create_security_user.sh $ORACLE_SID

exit

sqlplus -s << EOF >> $log_file
$securitysaveusername/$securitysaveuserpwd
set head off
prompt Running .............................. aa_sys_config_rollfwd

exit;
EOF
