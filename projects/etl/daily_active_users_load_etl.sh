#!/bin/bash
#set -x
 
if [ $# -ne 2 ]
then
   echo " "
   echo "Usage is : $0 <number of days delta> <ORACLE_SID>"
   echo " "
   exit 1
fi

export MAILDBA=dba@ifwe.co
##export MAILDBA=falramahi@ifwe.co
export ORACLE_SID=$2
export jobname=daily_active_users
export jobdir=/mnt/dba/projects/etl
export orapass=/home/oracle/.orapass
export today=`date +%d-%b-%Y-%H-%M-%S`
export logfile=/mnt/dba/logs/$ORACLE_SID/${jobname}_${today}.log
export ORACLE_BASE=/u01/app/oracle;
export ORACLE_HOME=`cat /etc/oratab | egrep -v "^$|^#|^-" | grep -v \* | cut -d: -f2 | tail -1`
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export TERM=vt100;
export PATH=/bin:/usr/bin:/opt/bin:/usr/ccs/bin:/usr/openwin/bin:/etc:$ORACLE_HOME/bin:
export delta=`date +%d-%b-%Y --date="$1 day ago"`
echo  "******************"  >> $logfile
echo `date +%Y-%m-%d:%H:%M:%S` >> $logfile
echo  "******************"  >> $logfile
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

cd $jobdir


##Removing old files

##mv  $jobdir/*.dump $jobdir/archive/ 2>/dev/null
##mv  $jobdir/log_* $jobdir/archive/  2>/dev/null

echo "" >> $logfile
echo "Check connection to Oracle" >> $logfile
echo "" >> $logfile

# This is the old line
# sqlplus -L -s `cat $orapass`@${ORACLE_SID}<<EOFCHECK>>$logfile

sqlplus -L -s `cat $orapass`<<EOFCHECK>>$logfile
  set feedback off
  set echo off
  select sysdate from dual;
  exit;
EOFCHECK


cat $logfile | grep -E 'error|ERROR|ORA-'
if [ $? -eq 0 ]; then
   echo "daily_active_users table load has falied. Database connection issues" | mail -s "[$jobname] on $ORACLE_SID  load failed." $MAILDBA
   echo "daily_active_users table load has falied. Database connection issues" >> $logfile
   exit 1;
fi

echo "" >> $logfile
echo "Oracle connection is ok." >> $logfile
echo "" >> $logfile


echo "" >> $logfile
echo "Cleaning and loading ${delta} partition" >> $logfile
echo "" >> $logfile


sqlplus -L -s `cat $orapass`<<EOFINSERT>>$logfile
  set timing on
  set feedback on
  set echo on
  delete from tag.daily_active_users where dt = to_date('${delta}','DD-MON-RRRR');
  INSERT INTO    
        tag.daily_active_users
        (select to_date('${delta}','DD-MON-RRRR') dt,
                TEMP_DAU.user_id,
                nvl(active_days,0) active_days
        FROM
                (SELECT user_id,
                        COUNT(*) active_days
                FROM    TAG.DAILY_ACTIVE_USERS dau
                WHERE   to_date(dau.dt,'DD-MON-RRRR') >= to_date('${delta}','DD-MON-RRRR') - 30
                    AND to_date(dau.dt,'DD-MON-RRRR')  < to_date('${delta}','DD-MON-RRRR')
                GROUP BY user_id
                ) days_30
        RIGHT JOIN
                (SELECT user_id,
                        MAX(TRUNC(dt)) dt
                FROM    event.page_view_event partition FOR (to_date('${delta}','DD-MON-RRRR'))
                WHERE   user_id >0
                GROUP BY user_id
                UNION
                SELECT  user_id,
                        MAX(TRUNC(dt)) dt
                FROM    event.login_event partition FOR (to_date('${delta}','DD-MON-RRRR'))
                WHERE   user_id >0
                    AND status  = 'success'
                GROUP BY user_id
                ) TEMP_DAU
        ON      days_30.user_id = temp_dau.user_id
        );
COMMIT;
  exit;
EOFINSERT

echo  "******************"  >> $logfile
echo `date +%Y-%m-%d:%H:%M:%S` >> $logfile
echo  "******************"  >> $logfile
echo "" >>  $logfile

cat $logfile | grep -E 'error|ERROR|ORA-' 
if [ $? -eq 0 ]; then
   echo "daily_active_users table insert has falied. Errors in  $logfile" | mail -s "[$jobname]  $ORACLE_SID load failed." $MAILDBA
   echo "daily_active_users table insert has falied." >> $logfile
   exit 1;
fi

echo "" >> $logfile
echo "Loading ${delta} partition is complete" >> $logfile
echo "" >> $logfile

