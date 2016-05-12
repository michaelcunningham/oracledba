#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <partition>"
  echo
  echo "   Example: $0 orcl 63"
  echo
  exit
fi

export ORACLE_SID=$1
export partition=$2

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

. /mnt/dba/admin/dba.lib

dat_dir=/mnt/db_transfer/external
dat_file=${dat_dir}/${ORACLE_SID}_apps_pets_${partition}.dat
email_body_file=${dat_dir}/${ORACLE_SID}_apps_pets_${partition}.email

username=tag
userpwd=`get_user_pwd $ORACLE_SID $username`

sqlplus -s $username/$userpwd << EOF > $dat_file
set linesize 400
set feedback off
set pagesize 0

select '' ||
pkey||','||
user_id||','||
owner_id||','||
date_bought||','||
price||','||
wishers||','||
pets||','||
total_pets_values||','||
cash||','||
date_last_rewarded||','||
price_bought||','||
date_last_purchased||','||
state ||','||
n_price ||','||
n_total_pets_values ||','||
n_cash ||','||
n_price_bought
from apps_pets partition ( p${partition} );

exit;
EOF

exit

#echo '' >> $dat_file
#echo '' >> $dat_file
#echo 'This report created by : '$0' '$* >> $dat_file

if [ -s $dat_file ]
then
	echo "List of invalid database links in the "$ORACLE_SID" database." > $email_body_file
	echo "" >> $email_body_file
	cat $dat_file >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file
	echo 'This report created by : '$0 >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file

	mail_subj=`echo $ORACLE_SID | awk '{print toupper($0)}'`" - Invalid Objects"
	mail -s "${ORACLE_SID} DB Link report" mcunningham@ifwe.co < $email_body_file
fi

