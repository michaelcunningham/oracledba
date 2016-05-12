#!/bin/sh
#
if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <volume_name_to_split>"
  echo
  echo "        Example : $0 tdcqa"
  echo
  exit
else
  export volume_name=$1
fi

log_file=/dba/admin/log/${volume_name}_clone_split_report.log

filer_name=`df -P -m | grep ${volume_name}$ | cut -d: -f1 | uniq`
echo "filer_name "$filer_name

echo "${volume_name} clone split started at   : `date`" > $log_file

rsh $filer_name vol clone split start ${volume_name}
echo '
     ************************************************************
     *****                                                  *****
     *****  Clone split started.                            *****
     *****                                                  *****
     ************************************************************
'
sleep 5

#
# Run a while loop until expected status is received.
#
clone_status=`rsh $filer_name vol clone split status $volume_name`
clone_status_pct=`echo $clone_status | awk '{sub(/\(/,"");sub(/\)/,"");print$8}'`
#echo $clone_status
#echo $clone_status_pct

#
# The next test will return an empty string when the clone is complete.
# Continue until an empty string is returned.
#
clone_complete=`rsh $filer_name vol status $volume_name | grep "Clone"`
#echo "COMPLETE "$clone_complete

while [ "$clone_complete" != "" ]
do
        sleep 30 # 30 Sec interval
        clone_status=`rsh $filer_name vol clone split status $volume_name`
        echo $clone_status
        clone_complete=`rsh $filer_name vol status $volume_name | grep "Clone"`
done

sleep 5

rsh $filer_name snap reserve $volume_name 0

echo "${volume_name} clone split completed at : `date`" >> $log_file
mail -s "${volume_name} volume split report" mcunningham@thedoctors.com < $log_file
mail -s "${volume_name} volume split report" swahby@thedoctors.com < $log_file
