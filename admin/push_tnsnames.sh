#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <remote host> <name of tnsnames.ora file>"
  echo
  echo "   Example: $0 ora39 tnsnames.ora"
  echo
  exit
else
  export remote_host=$1
  export tns_file=$2
fi

remote_homes=`ssh $remote_host cat /etc/oratab | grep '[YN]$' | cut -d: -f2 | uniq`

for this_remote_home in $remote_homes
do
  echo $this_remote_home
done
