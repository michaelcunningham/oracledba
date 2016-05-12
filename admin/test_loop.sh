#!/bin/sh

if [ "$1" = "" ]
then
  number_of_snapshots=7
else
  number_of_snapshots=$1
fi

snapshot_name=hot_snapshot
############################################################################
#
# Make a snapshot of the volume while the database is in backup mode.
#
############################################################################
this_snapshot=$number_of_snapshots
mycmd="rsh <filer_name> snap delete <ORACLE_SID> ${snapshot_name}.${number_of_snapshots}"
echo $mycmd

while [ $this_snapshot -gt 1 ]
do
  mycmd="rsh <filer_name> snap rename <ORACLE_SID> ${snapshot_name}.`expr $this_snapshot - 1` ${snapshot_name}.${this_snapshot}"
  echo $mycmd

  this_snapshot=`expr $this_snapshot - 1`
done

mycmd="rsh <filer_name> snap create <ORACLE_SID> ${snapshot_name}.${this_snapshot}"
echo $mycmd

exit 0
