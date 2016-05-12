#!/bin/sh

# This script will check the Oracle HAS configuration using srvctl.
# If the configuration is not correct it will produce a statement
# that can be used to fix it.

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

db_unique_name=`srvctl config database | grep $ORACLE_SID`

if [ -z $db_unique_name ]
then
  config_needed=1

db_unique_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select db_unique_name from v\\$database;
exit;
EOF`
db_unique_name=`echo $db_unique_name`

fi

# For now this is being set to detect if version 12.1.0.2.0 is being used.
# If it is then we will do things a little bit differently
# The following will return the 2 in 12.1.0.2.0
srvctl_version=`srvctl -V | cut -d: -f2 | cut -d. -f4`

# Make a | delimited string
asm_info=`srvctl config database -db $db_unique_name | tr '\n' '|'`
# db_unique_name=`echo $asm_info | cut -d'|' -f1 | cut -d':' -f2`
db_name=`echo $asm_info | cut -d'|' -f2 | cut -d':' -f2`
db_home=`echo $asm_info | cut -d'|' -f3 | cut -d':' -f2`
db_user=`echo $asm_info | cut -d'|' -f4 | cut -d':' -f2`
db_spfile=`echo $asm_info | cut -d'|' -f5 | cut -d':' -f2`
db_pwfile=`echo $asm_info | cut -d'|' -f6 | cut -d':' -f2`
db_domain=`echo $asm_info | cut -d'|' -f7 | cut -d':' -f2`
db_startoption=`echo $asm_info | cut -d'|' -f8 | cut -d':' -f2`
db_stopoptions=`echo $asm_info | cut -d'|' -f9 | cut -d':' -f2`
db_role=`echo $asm_info | cut -d'|' -f10 | cut -d':' -f2`
db_policy=`echo $asm_info | cut -d'|' -f11 | cut -d':' -f2`

if [ "$srvctl_version" = "2" ]
then
  db_instance_name=`echo $asm_info | cut -d'|' -f16 | cut -d':' -f2`
  db_diskgroup=`echo $asm_info | cut -d'|' -f12 | cut -d':' -f2`
else
  db_instance_name=`echo $asm_info | cut -d'|' -f12 | cut -d':' -f2`
  db_diskgroup=`echo $asm_info | cut -d'|' -f13 | cut -d':' -f2`
fi

db_services=`echo $asm_info | cut -d'|' -f14 | cut -d':' -f2`

# chomp all the variables
db_name=`echo $db_name`
db_home=`echo $db_home`
db_user=`echo $db_user`
db_spfile=`echo $db_spfile`
db_pwfile=`echo $db_pwfile`
db_domain=`echo $db_domain`
db_startoption=`echo $db_startoption`
db_stopoptions=`echo $db_stopoptions`
db_role=`echo $db_role`
db_policy=`echo $db_policy`
db_instance_name=`echo $db_instance_name`
db_diskgroup=`echo $db_diskgroup`
db_services=`echo $db_services`

# echo "asm_info          = "$asm_info
echo "db_unique_name    = "$db_unique_name
echo "db_name           = "$db_name
echo "db_home           = "$db_home
echo "db_user           = "$db_user
echo "db_spfile         = "$db_spfile
echo "db_pwfile         = "$db_pwfile
echo "db_domain         = "$db_domain
echo "db_startoption    = "$db_startoption
echo "db_stopoption     = "$db_stopoptions
echo "db_role           = "$db_role
echo "db_policy         = "$db_policy
echo "db_instance_name  = "$db_instance_name
echo "db_diskgroup      = "$db_diskgroup
echo "db_services       = "$db_services
echo "ORACLE_HOME       = "$ORACLE_HOME

if [ -z "$db_name" ]
then
  db_name=$ORACLE_SID
  if [ -n $db_name ]
  then
    configure_cmd=$configure_cmd" -dbname "$db_name
  fi
fi

if [ -z $db_spfile ]
then
db_spfile=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'spfile';
exit;
EOF`
  db_spfile=`echo $db_spfile`
  if [ -n "$db_spfile" ]
  then
    configure_cmd=$configure_cmd" -spfile "$db_spfile
  fi
fi

if [ -z $db_pwfile ]
then
  pwfile_name=$ORACLE_HOME/dbs/orapw$ORACLE_SID
  if [ -e $pwfile_name ]
  then
    configure_cmd=$configure_cmd" -pwfile "$pwfile_name
  fi
fi

if [ -z $db_role ]
then
database_role=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select database_role from v\\$database;
exit;
EOF`

  database_role=`echo $database_role`

  if [ "$database_role" = "PRIMARY" ]
  then
    db_startoption=open
    db_role=PRIMARY
    db_policy=AUTOMATIC
  elif [ "$database_role" = "PHYSICAL STANDBY" ]
  then
    db_startoption=mount
    db_role=PHYSICAL_STANDBY
    db_policy=AUTOMATIC
  fi
  configure_cmd=$configure_cmd" -startoption "$db_startoption" -role "$db_role" -policy "$db_policy
fi

if [ -z $db_home ]
then
  db_home=$ORACLE_HOME
  configure_cmd=$configure_cmd" -oraclehome "$db_home
fi

if [ -z $db_diskgroup ]
then
  export db_diskgroup=`/mnt/dba/admin/asm_get_dg_delimited_by_comma.sh`
  configure_cmd=$configure_cmd" -diskgroup "$db_diskgroup
fi

if [ -n "$configure_cmd" ]
then
  if [ $config_needed ]
  then
    configure_cmd="srvctl add database -db "$db_unique_name" -dbname "$ORACLE_SID" -instance "$ORACLE_SID" "$configure_cmd
    $configure_cmd
  else
    configure_cmd="srvctl modify database -db "$db_unique_name" "$configure_cmd
  fi
  echo $configure_cmd
fi

