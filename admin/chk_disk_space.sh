#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <filesystem> <max_used_percentage_email> [max_used_percentage_page]"
  echo
  echo "   Example: $0 /mnt/oralogs 85 [95 default]"
  echo
  exit
fi

chk_vol="$1"
chk_pct="$2"

if [ "$3" = "" ]
then
  chk_pct_page=95
else
  chk_pct_page="$3"
fi

EMAILDBA="dba@ifwe.co"
PAGEDBA="dbaoncall@ifwe.co"
#EMAILDBA="falramahi@ifwe.co"
#PAGEDBA="falramahi@ifwe.co"
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs
email_body_file=${log_dir}/${HOST}_chk_disk_space_${log_date}.email
mkdir -p $log_dir

pct_used=`df -P -m | grep ${chk_vol}$ | awk '{sub(/%/,"");print$5}'`

# chk_vol=`echo ${chk_vol} | awk '{sub(/\//,"");print $1}'`

if [ "${pct_used}" = "" ]
then
  # This means the filesystem mount point was not found.
  echo "No pct_used value."
  exit
fi

# echo "email_body_file    = "$email_body_file
# echo "chk_vol            = "$chk_vol
# echo "chk_pct            = "$chk_pct
# echo "pct_used           = "$pct_used

if [ "${pct_used}" -gt "${chk_pct}" ]
then
  if [ "${pct_used}" -gt "${chk_pct_page}" ]
  then
    this_pct=$chk_pct_page
    email_subj="CRITICAL: DISK SPACE on ${HOST} - ${chk_vol}=${pct_used}%"
    MAILTO=$PAGEDBA
  else
    this_pct=$chk_pct
    email_subj="WARNING: DISK SPACE on ${HOST} - ${chk_vol}=${pct_used}%"
    MAILTO=$EMAILDBA
  fi

  echo "The disk space usage is high for the "$chk_vol" filesystem" > $email_body_file
  echo "The % used should not be more than "$this_pct"%" >> $email_body_file
  echo "The current % used is "$pct_used"%" >> $email_body_file
  echo "" >> $email_body_file
  echo "################################################################################" >> $email_body_file
  echo "" >> $email_body_file
  echo 'This report created by : '$0 >> $email_body_file
  echo "" >> $email_body_file
  echo "################################################################################" >> $email_body_file
  echo "" >> $email_body_file

  mail -s "$email_subj" $MAILTO < $email_body_file
  rm $email_body_file
fi
