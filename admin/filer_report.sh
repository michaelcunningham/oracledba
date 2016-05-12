#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <filer>"
  echo
  echo "	Example : $0 npnetapp109"
  echo
  exit
fi

export filer_name=$1

log_date=`date +%a`
log_file=/dba/admin/log/${filer_name}_filer_report.txt

rsh $filer_name df -m | grep -v .snapshot | grep -v ^snap | \
  sed "s/MB//g" | awk '{printf("%s\t%s\t%s\t%s\t%s\t%s\n", $1,$2,$3,$4,$5,$6)}' > $log_file

echo "Volume usage report" | mutt -s "$filer_name" mcunningham@thedoctors.com -a $log_file

