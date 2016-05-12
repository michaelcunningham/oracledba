#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <source volume name>"
  echo
  echo "	Example: $0 tdcprd"
  echo
  exit 2
else
  export source_volume_name=$1
fi

filer_name=`df -P -m | grep $source_volume_name | cut -d: -f1 | uniq`

volume_list=`rsh $filer_name vol status | grep online | awk '{print $1}'`

for this_volume in $volume_list
do
volume_clone=`rsh $filer_name vol status $this_volume | grep Clone | grep $source_volume_name"'"`
if [ "$volume_clone" != "" ]
then
  echo $this_volume' '$volume_clone
fi
done

