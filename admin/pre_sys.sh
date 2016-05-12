
ORATAB=/etc/oratab
export ORAENV_ASK=NO
cat $ORATAB | grep -v "^#" | grep -v "^$" | while read LINE
do
  ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`

  if [ "$ORACLE_SID" = '*' ] ; then
    ORACLE_SID=""
  fi

  export ORACLE_SID
  . /usr/local/bin/oraenv -s

  if [ "$ORACLE_SID" != "" ]
  then
    pmon=`ps -ef | egrep pmon_$ORACLE_SID  | grep -v grep`
    if [ "$pmon" != "" ];
    then
      echo 
      echo "##################################################"
      echo "#####"
      echo "#####  Shutting down \"${ORACLE_SID}\" database."
      echo "#####"
      echo "##################################################"
sqlplus /nolog << EOF
connect / as sysdba
shutdown immediate
EOF
    else
      echo "Database \"${ORACLE_SID}\" is not running."
    fi
  fi
done
