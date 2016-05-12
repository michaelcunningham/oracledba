#!/bin/sh

admin_dir=/oracle/app/oracle/admin
admin_dirs=`ls -l $admin_dir | grep "^d" | awk '{print $9}'`
# admin_dirs=`ps -ef | grep pmon | grep -v "grep pmon" | cut -f3 -d_`
node_name=`uname -n | cut -f1 -d.`
log_date=`date +%a`

for this_dir in $admin_dirs
do
  backup_dir_name=/dba/admin_backup/${node_name}_${this_dir}_${log_date}
  if [ -d $backup_dir_name ] ; then
    rm -r $backup_dir_name
    mkdir -p $backup_dir_name
  fi

  for sub_dir in adhoc create dpdump export pfile scripts
  do
    # echo $this_dir
    # echo $admin_dir/$this_dir/$sub_dir
    # echo $backup_dir_name
    if [ -d $admin_dir/$this_dir/$sub_dir ] ; then
      mkdir -p $backup_dir_name/$sub_dir
      cp -r -p $admin_dir/$this_dir/$sub_dir $backup_dir_name
    fi
  done
  #
  # We also want to backup files from the $ORACLE_HOME/dbs directory
  # but only if we can figure out which oracle home the db belongs with.
  #
  mkdir -p $backup_dir_name/dbs

  export ORACLE_SID=$this_dir
  is_db_running=`ps -ef | grep pmon_${ORACLE_SID} | grep -v "grep pmon" | cut -f3 -d_`
  if [ "$is_db_running" = "$ORACLE_SID" ]
  then
    export ORAENV_ASK=NO
    . /usr/local/bin/oraenv

    # echo $ORACLE_HOME
    if [ "$ORACLE_HOME" = "" ]
    then
      ORACLE_HOME=/oracle/app/oracle/product/11.2.0/dbhome_1
    fi
    cp -r -p $ORACLE_HOME/dbs/*${ORACLE_SID}* $backup_dir_name/dbs
  fi
done

