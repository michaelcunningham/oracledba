#!/bin/sh
export PATH=/usr/local/bin:$PATH

function initialize() {
  branch=$1
  echo "$(date) cd ${GIT_REPOSITORY_PATH}/tag" >> $LOGFILE
  cd $GIT_REPOSITORY_PATH/tag
  
  echo "$(date) git checkout ${branch}" >> $LOGFILE
  git checkout $branch >> $LOGFILE 2>&1

  echo "$(date) git pull" >> $LOGFILE
  git pull >> $LOGFILE 2>&1
}

function take_dev_snapshot () {
   databases=("DEVPDB" "DTDB" "DEVTAGDB" "DWHSE" "DMMDB" "DETL")
   sids=("DEVPDB01" "DTDB00" "DEVTAGDB" "DWHSE" "DMMDB01" "DETL")

   #databases=("DEVTAGDB")
   #sids=("DEVTAGDB") 

   echo "Total DATABASES: ${#databases[@]}" >> $LOGFILE
   index=0
   resp=0

   for db in ${databases[@]}
   do
      echo "Processing: ${db} ${sids[$index]}"  >> $LOGFILE
      take_snapshot ${db} ${sids[$index]}
      lresp=$?

      if [ $lresp -ne 0 ]
      then
          resp=$lresp
      fi

      if [ $resp -ne 0 ] && [ $resp -ne 2 ]
      then
         return 1;
      fi
      index=`expr $index + 1`

   done
   commit_to_repo;
   return $resp;
}

function take_stage_snapshot () {
   databases=("STAGEPDB" "STDB" "STAGETAGDB" "SWHSE" "SMMDB" "SETL")
   sids=("SPDB01" "STDB00" "STAGDB" "SWHSE" "SMMDB01" "SETL")

   echo "Total DATABASES: ${#databases[@]}"  >> $LOGFILE
   index=0
   resp=0

   for db in ${databases[@]}
   do
      #echo "Processing: ${db} ${sids[$index]}"  >> $LOGFILE
      take_snapshot ${db} ${sids[$index]}
      lresp=$?

      if [ $lresp -ne 0 ]
      then
          resp=$lresp
      fi

      if [[ ($resp -ne 0) && ($resp -ne 2) ]]
      then
         return 1;
      fi
      index=`expr $index + 1`
   done
   commit_to_repo;
   return $resp;
}

function take_prod_snapshot () {
   databases=("PDB" "TDB" "TAGDB" "WHSE" "MMDB" "ETL")
   sids=("PDB01" "TDB00" "TAGDB" "WHSE" "MMDB01" "ETL")

   #databases=("TAGDB")
   #sids=("TAGDB")

   echo "Total DATABASES: ${#databases[@]}"  >> $LOGFILE
   index=0
   resp=0

   for db in ${databases[@]}
   do
      resp=0
      #echo "Processing: ${db} ${sids[$index]}"  >> $LOGFILE
      take_snapshot ${db} ${sids[$index]}
      lresp=$?
 
      echo "${sids[$index]} $lresp" >> $LOGFILE

      if [ $lresp -ne 0 ]
      then
          resp=$lresp
      fi

      echo "${sids[$index]} $lresp $resp " >> $LOGFILE
      if [[ ( $resp -ne 0 ) && ( $resp -ne 2 )  ]]
      then
         return 1;
      fi
      index=`expr $index + 1`
   done
   commit_to_repo;
   return $resp;
}


function take_snapshot () {
    db=$1
    unset SQLPATH
    ORACLE_SID=$2
    SCRIPT_LOG=/mnt/dba/logs/${ENVIRONMENT}_${ORACLE_SID}_schema_snapshots.log
    lock_file=/tmp/${db}.lock;
    respCode=0

    echo "============================== STARTING ================================== " > $SCRIPT_LOG
    echo "DB=${db} SID=${ORACLE_SID}" >> $SCRIPT_LOG
    echo "Log=${SCRIPT_LOG} lock=${lock_file}" >> $SCRIPT_LOG

    echo "============================== ${ORACLE_SID}  ============================== " >> $LOGFILE
    echo "Processing DB=${db} SID=${ORACLE_SID}" >> $LOGFILE
    echo "For Full Details check file: ${SCRIPT_LOG} " >> $LOGFILE 

    echo "touch ${lock_file}" >> $SCRIPT_LOG
    touch ${lock_file} >> $SCRIPT_LOG

    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Functions" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Functions"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Sequence" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Sequence"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Procedure" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Procedure"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/DBLink" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/DBLink"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Package" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Package"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Trigger" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Trigger"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/View" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/View"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Index" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Index"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Table"  >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Table"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Constraint" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Constraint"
    echo mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/MaterializedView" >> $SCRIPT_LOG
    mkdir -p "/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/MaterializedView"
    exec_sql ${db} ${ORACLE_SID}

    status=`cat $SCRIPT_LOG | grep "ORA-"`

    #cat $SCRIPT_LOG >> $LOGFILE

    if [ ! -z "$status" ] 
    then
        echo "$status" >> $LOGFILE
        app_status=`echo $status | grep ORA-20343`
        if [ ! -z "$app_status" ]
        then
            echo "============================== Finished ${ORACLE_SID}  ============================== " >> $LOGFILE
            echo "============================== Finished ${ORACLE_SID}  =============================== " >> $SCRIPT_LOG
            return 3;
        fi

        app_status=`echo $status | grep -i -E "ORA-12541|ORA-12547"`

        if [ ! -z "$app_status" ]
        then
            echo "============================== Finished ${ORACLE_SID}  ============================== " >> $LOGFILE
            echo "============================== Finished ${ORACLE_SID}  =============================== " >> $SCRIPT_LOG
            return 1;
        fi       

        app_status=`echo $status | grep ORA-06512`

        if [ ! -z "$app_status" ]
        then
            echo "============================== Finished ${ORACLE_SID}  ============================== " >> $LOGFILE
            echo "============================== Finished ${ORACLE_SID}  =============================== " >> $SCRIPT_LOG
            respCode=2;
        else
            return 1
        fi
    fi 

    find_objects_to_delete ${lock_file} ${db}
    echo  "rm -f ${lock_file}" >> $SCRIPT_LOG
    rm -f ${lock_file} 
    echo "============================== Finished ${ORACLE_SID}  ============================== " >> $LOGFILE
    return $respCode;
}

function exec_sql(){
   echo "Connecting to $ORACLE_SID" >> $SCRIPT_LOG
   db=$1
   sid=$2
   echo "Repository DATABASE ${db} SID=${sid}" >> $SCRIPT_LOG
sqlplus -s /nolog << EOF >> $SCRIPT_LOG
set echo on time on timing on
set heading on
set serveroutput on
connect sys/admin123@${sid} as sysdba
create or replace directory SCHEMA_FUNC_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Functions';
create or replace directory SCHEMA_SEQ_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Sequence';
create or replace directory SCHEMA_PROC_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Procedure';
create or replace directory SCHEMA_DBLINK_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/DBLink';
create or replace directory SCHEMA_PKG_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Package';
create or replace directory SCHEMA_TRG_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Trigger';
create or replace directory SCHEMA_VIEW_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/View';
create or replace directory SCHEMA_INDEX_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Index';
create or replace directory SCHEMA_TABLE_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Table' ;
create or replace directory SCHEMA_CONSTR_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/Constraint';
create or replace directory SCHEMA_MV_SRC as '/mnt/dba/projects/schema_snapshots/${ENVIRONMENT}/schemas/tag/${db}/MaterializedView';
exit;
EOF

echo "Starting importing objects from tag schema" >> $SCRIPT_LOG

sqlplus -s /nolog << EOF >> $SCRIPT_LOG
connect sys/admin123@${sid} as sysdba
set echo on time on timing on
set heading on
set serveroutput on
set pagesize 1000
set linesize 9999
@/mnt/dba/scripts/schema_snapshot.sql
exit;
EOF

echo "Finished importing objects from tag schema" >> $SCRIPT_LOG
}

function find_objects_to_delete() {
  lock_file=$1
  db=$2
  echo $lock_file >> $SCRIPT_LOG
  echo "find ${GIT_REPOSITORY_PATH}/tag/${db} -type d -name .git -prune -o -type f ! -newer $lock_file -print" >> $SCRIPT_LOG
  FILES=`find ${GIT_REPOSITORY_PATH}/tag/${db} -type d -name .git -prune -o -type f ! -newer $lock_file -print`
  for i in $FILES
  do
    file=${i}
    echo "Removing file: ${file}" >> $SCRIPT_LOG
    echo " rm -f ${file}" >> $SCRIPT_LOG
    rm -f ${file}
  done
}

function commit_to_repo(){
   time=`date`
   echo "git add -A" >> $LOGFILE
   git add -A >> $LOGFILE 2>&1
   echo "git commit -m 'Committing changes on $time'" >> $LOGFILE 2>&1
   git commit -m "Committing changes on $time" >> $LOGFILE 2>&1
   git push >> $LOGFILE 2>&1
}

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/10.2
export LD_LIBRARY_PATH=/u01/app/oracle/product/10.2/lib
export PATH=$ORACLE_HOME/bin:/usr/local/bin:/usr/bin:/bin

CUR_PWD=`pwd`
ROOT_DIRECTORY=$1
ENVIRONMENT=$2
GIT_REPOSITORY_PATH="${ROOT_DIRECTORY}/${ENVIRONMENT}/schemas"
#MAILDBA=vadim@ifwe.co
MAILDBA=dba@ifwe.co
LOGFILE="/mnt/dba/logs/${ENVIRONMENT}_databases_schema_snapshots.log"

echo "$(date) starting ${ENVIRONMENT} schema snapshot" > $LOGFILE
echo "$(date) ${GIT_REPOSITORY_PATH}" >> $LOGFILE
echo "$(date) ${CUR_PWD} " >> $LOGFILE

echo "$(date) Starting taking snapshot from ${ENVIRONMENT} databases" >> $LOGFILE
if [ "${ENVIRONMENT}" = "dev" ]
then
    initialize dev
    take_dev_snapshot
elif [ "${ENVIRONMENT}" = "stage" ]
then
    
    initialize stage
    take_stage_snapshot
elif [ "${ENVIRONMENT}" = "prod" ]
then
    initialize prod
    take_prod_snapshot
else
   echo "Unknown environments ${ENVIRONMENT}"
fi
resp=$?
subject="finished successfully"
if [ $resp -ne 0 ] && [ $resp -ne 2 ]
then
   subject="with some failures"
elif [ $resp -eq 2 ]
then
   subject="successfully with some errors"
fi
msgs="$(date) DB Schema Repository Refresh completed on ${ENVIRONMENT} ${subject}"

echo "${msgs}" >> $LOGFILE

mail -s "${msgs}" $MAILDBA < $LOGFILE
cd $CUR_PWD
exit 0
