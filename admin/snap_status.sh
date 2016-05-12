#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <volume_name> [filer_name]"
  echo
  echo "	Example: $0 novadev npnetapp109"
  echo
  exit 2
else
  export volume_name=$1
  export filer_name=`df -P -m | grep ${volume_name}$ | cut -d: -f1 | uniq`
fi

if [ "$2" != "" ]
then
  filer_name=$2
fi

#echo $volume_name
#echo $filer_name

if [ "$filer_name" = "" ]
then
  echo
  echo "Cannot find the filer for the $volume_name volume."
  echo "It might not be located on this machine."
  echo
  exit 3
fi

#echo $filer_name

#
# Run a while loop until expected status is received.
#
mir_status=`rsh ${filer_name} snapmirror status | grep "${volume_name} " | awk '{print $3$5}'`
while [ "$mir_status" != "SnapmirroredIdle" ]
do
        mir_status=`rsh ${filer_name} snapmirror status | grep "${volume_name} "`
        echo "$mir_status"
        sleep 15 # 15 Sec interval
        #mir_status=`rsh ${filer_name} snapmirror status | grep "${volume_name} "`
        #echo "$mir_status"
        mir_status=`rsh ${filer_name} snapmirror status | grep "${volume_name} " | awk '{print $3$5}'`
done

