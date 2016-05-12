#!/bin/sh

if [ "$1" = "" ]
then
  echo "Usage: $0 <sh script to run>"
  exit
fi

sh_file=$1

if [ ! -f $sh_file ]
then
  echo The file $sh_file does not exist.
  exit
fi

sid_list=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB" | sort`

for this_sid in $sid_list
do
  unset SQLPATH
  export PATH=/usr/local/bin:$PATH
  export ORACLE_SID=$this_sid
  ORAENV_ASK=NO . /usr/local/bin/oraenv -s

  nohup $sh_file $ORACLE_SID &
done
