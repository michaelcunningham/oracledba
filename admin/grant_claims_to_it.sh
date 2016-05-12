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
log_file=$log_dir/grant_claims_to_it_$log_date.log

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

INSERT INTO EM_CLAIM_ACCESS_GRANT
   SELECT SEQ_EM_CLAIM_ACCESS_GRANT.nextval
      ,fromEmp.EMPLOYEE_ID fromEmployee_id
      ,toEmp.employee_id toEmployee_id
      ,'DBRefresh'
      ,SYSDATE
      ,NULL
      ,NULL
   FROM   EM_EMPLOYEE fromEmp
         ,EM_EMPLOYEE toEmp
   WHERE 
        fromEmp.employee_id <> toEmp.Employee_id
     AND toEmp.EMPLOYEE_STATUS_ID = 'A' 
     AND toEmp.TDC_Department_id = 'IT' 
     AND fromEmp.EMPLOYEE_STATUS_ID = 'A'      
     AND  NOT EXISTS
         ( select 1 from EM_CLAIM_ACCESS_GRANT
           where EM_CLAIM_ACCESS_GRANT.GRANT_FROM_EMPLOYEE_ID = fromEmp.employee_id 
             AND EM_CLAIM_ACCESS_GRANT.GRANT_TO_EMPLOYEE_ID = toEmp.employee_id
         )
      AND EXISTS
         (  SELECT 1
            FROM EM_EMPLOYEE_ROLE rol
            WHERE rol.employee_id = fromEmp.Employee_id
             AND ROL.EMPLOYEE_ROLE_TYPE_ID in ('CS', 'CR', 'RM')
             AND ROL.RECORD_IS_DELETED_FLAG = 0 -- added this condition to check for possible logical-deletes
   );
commit;
exit;

EOF

