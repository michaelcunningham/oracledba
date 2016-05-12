#!/bin/sh
export PATH=/usr/local/bin:$PATH

function initialize() {
  branch=$1
  echo "cd $GIT_REPOSITORY_PATH/tag"
  cd $GIT_REPOSITORY_PATH/tag
  
  echo "git checkout $branch"
  git checkout $branch

  echo "git pull"
  git pull
}

function take_dev_snapshot () {
   databases=("DEVPDB" "DTDB" "DEVTAGDB" "DWHSE" "DMMDB" "DETL")
   sids=("DEVPDB01" "DTDB00" "DEVTAGDB" "DWHSE" "DMMDB01" "DETL")
 
   echo "Total DATABASES: ${#databases[@]}"
   for ((i=0;i<${#databases[@]};i++))
   do
      echo "Processing: ${databases[$i]}"
      take_snapshot ${databases[$i]} ${sids[$i]}
   done
   commit_to_repo;
}

function take_stage_snapshot () {
   databases=("STAGEPDB" "STDB" "STAGETAGDB" "SWHSE" "SMMDB" "SETL")
   sids=("STGPRT01" "STDB00" "STAGE1" "SWHSE" "SMMDB01" "SETL")

   echo "Total DATABASES: ${#databases[@]}"
   index=0
   for db in ${databases[@]}
   do
      echo "Processing: ${db} ${sids[$index]}"
      take_snapshot ${db} ${sids[$index]}
      index=`expr $index + 1`
   done
   commit_to_repo;
}

function take_prod_snapshot () {
   databases=("PDB" "TDB" "TAGDB" "WHSE" "MMDB" "ETL")
   sids=("PDB01" "TDB00" "TAGDB" "WHSE" "MMDB01" "ETL")


   echo "Total DATABASES: ${#databases[@]}"
   index=0
   for db in ${databases[@]}
   do
      echo "Processing: ${db} ${sids[$index]}"
      take_snapshot ${db} ${sids[$index]}
      index=`expr $index + 1`
   done
   commit_to_repo;
}


function take_snapshot () {
    db=$1
    unset SQLPATH
    ORACLE_SID=$2
    SCRIPT_LOG=/mnt/dba/logs/${ENVIRONMENT}_${ORACLE_SID}_schema_snapshots.log
    lock_file=/tmp/${db}.lock;

    echo > $SCRIPT_LOG
    echo "DB=${db} SID=${ORACLE_SID}" >> $SCRIPT_LOG
    echo "Log=${SCRIPT_LOG} lock=${lock_file}" >> $SCRIPT_LOG
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
    find_objects_to_delete ${lock_file} ${db}
    echo  "rm -f ${lock_file}" >> $SCRIPT_LOG
    rm -f ${lock_file} >> $SCRIPT_LOG
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
@/mnt/dba/scripts/schema_snapshot.sql
exit;
EOF

echo "Finished importing objects from tag schema"
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
   echo "git add -A" 
   git add -A
   echo "git commit -m 'Committing changes on $time'"; 
   git commit -m "Committing changes on $time" 
   git push
}

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/10.2
export LD_LIBRARY_PATH=/u01/app/oracle/product/10.2/lib
export PATH=$ORACLE_HOME/bin:/usr/local/bin:/usr/bin:/bin

CUR_PWD=`pwd`
ROOT_DIRECTORY=$1
ENVIRONMENT=$2
GIT_REPOSITORY_PATH="${ROOT_DIRECTORY}/${ENVIRONMENT}/schemas"
echo $GIT_REPOSITORY_PATH
echo $CUR_PWD


if [ "${ENVIRONMENT}" = "dev" ]
then
    echo "init_dev"
    initialize dev
    take_dev_snapshot
    echo "Finished"
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
   exit 1; 
fi
echo "cd $CUR_PWD"
cd $CUR_PWD
exit 0
