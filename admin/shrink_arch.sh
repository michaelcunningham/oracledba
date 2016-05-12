#!/bin/sh
#
if [ "$1" = "" ]
then
  echo "Usage: $0 <archive_log_volume_name>"
  echo "Example: $0 snaparch"
  exit
else
  export VOL_NAME=$1
fi

echo '
     ************************************************************
     *****                                                  *****
     *****  Deleting archive log files.                     *****
     *****                                                  *****
     ************************************************************
'

filer_name=`df -P -m | grep $VOL_NAME | cut -d: -f1 | uniq`

archive_log_dir=/$VOL_NAME/arch

this_file=primer
while [ "$this_file" != "" ]
do
  this_file=`find ${archive_log_dir} -name "*.dbf" | head -1`
  if [ "$this_file" != "" ]
  then
#    echo "Deleting old file : "$this_file
    rm "$this_file"
  fi
done

sleep 15
rsh $filer_name vol size $VOL_NAME 2g
