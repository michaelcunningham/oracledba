#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 novadev"
  echo
  exit
else
  export this_sid=$1
fi

export ORACLE_SID=$this_sid
export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/11g_upgrade/set_upgrade_env.sh $ORACLE_SID

#grep $ORACLE_SID /etc/oratab
#echo $ORACLE_SID
#echo $ORACLE_HOME

# Let's fix the /etc/oratab file for 11g.
sed "s/${ORACLE_SID}:\/oracle\/app\/oracle\/product\/10.2.0\/db_1/${ORACLE_SID}:\/oracle\/app\/oracle\/product\/11.2.0\/dbhome_1/g" /etc/oratab > /tmp/oratab
cat /tmp/oratab > /etc/oratab
. ~/.bash_profile

# Now that we ran .bash_profile we need to reset our environment.
export ORACLE_SID=$this_sid
. /usr/local/bin/oraenv

#grep $ORACLE_SID /etc/oratab
#echo $ORACLE_SID
#echo $ORACLE_HOME

