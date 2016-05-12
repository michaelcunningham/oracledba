if [ "$1" = "" ]
then
  echo
  echo "        Usage: $0 <ORACLE_SID>"
  echo
  echo "        Example: $0 novadev"
  echo
  exit 2
else
  export ORACLE_SID=$1
fi

echo "######################################################"
echo "##"
echo "## Starting listener load for $ORACLE_SID"
echo "##"
echo "######################################################"

/dba/admin/listener_log/copy_listener_log_files.sh $ORACLE_SID
#/dba/admin/listener_log/initial_load_of_listener_log.sh $ORACLE_SID
#/dba/admin/listener_log/load_listener_log.sh
#/dba/admin/listener_log/delete_listener_log_files.sh $ORACLE_SID
