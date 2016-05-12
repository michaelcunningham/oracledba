#!/bin/sh
/dba/admin/chk_listener.sh

ORATAB=/etc/oratab
export ORAENV_ASK=NO
cat $ORATAB | grep -v "^#" | grep -v "^$" | while read LINE
do
  if [ "`echo $LINE | awk -F: '{print $3}' -`" = "Y" ] ; then
    ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`

    if [ "$ORACLE_SID" = '*' ] ; then
      ORACLE_SID=""
    fi

    export ORACLE_SID
    export ORAENV_ASK=NO
    . /usr/local/bin/oraenv

    pmon=`ps -ef | egrep pmon_$ORACLE_SID  | grep -v grep`
    if [ "$pmon" != "" ];
    then
      echo "Database \"${ORACLE_SID}\" already started."
    else
      echo
      echo "##################################################"
      echo "#####"
      echo "#####  Starting \"${ORACLE_SID}\" database."
      echo "#####"
      echo "##################################################"
sqlplus /nolog << EOF
connect / as sysdba
startup
EOF
    fi
  fi
done

