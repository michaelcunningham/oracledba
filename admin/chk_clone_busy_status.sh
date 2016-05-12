#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <volume name> [snapshot_name]"
  echo "	Example: $0 tdcprd post_cycle"
  echo
  exit 2
else
  export volume_name=$1
fi

if [ "$2" = "" ]
then
  snapshot_name=hot_backup
else
  snapshot_name=$2
fi

filer_name=`df -P -m | grep $volume_name | cut -d: -f1 | uniq`

log_date=`date +%a`
work_file=/dba/admin/log/${volume_name}_clone_status_$log_date.work
cloned_volume_file=/dba/admin/log/${volume_name}_clone_volumes_$log_date.work
mail_file=/dba/admin/log/${volume_name}_clone_status_$log_date.mail

#
# Find the snapshots still having clones that need to be split.
#

>$work_file
>$cloned_volume_file
>$mail_file

rsh $filer_name snap list $volume_name | grep vclone | sed "s/( /(/g" | while read LINE
do
  busy_clone=`echo $LINE | awk '{print $8}'`
  if [ $busy_clone != $snapshot_name'.1' ]
  then
    echo $busy_clone > $work_file
  fi
done

mail_subject='CLONE SPLIT WARNING (volume - '`hostname | cut -f1 -d.`':'$volume_name')'

if [ -s $work_file ]
then
  echo 'The following snapshots on volume '$volume_name' need to be split.' > $mail_file
  echo '' >> $mail_file
  cat $work_file >> $mail_file
  echo '' >> $mail_file
  echo '' >> $mail_file
  echo 'The following shows which clones depend on snapshots from volume '$volume_name >> $mail_file

  /dba/admin/find_cloned_volumes.sh ${volume_name} > ${cloned_volume_file}

  echo '' >> $mail_file
  cat $cloned_volume_file >> $mail_file
  echo '' >> $mail_file
  echo 'This report created by : '$0' '$* >> $mail_file
  mail -s "$mail_subject" `cat /dba/admin/dba_team` < $mail_file
fi

rm $work_file
rm $cloned_volume_file
