#!/bin/sh

export ORACLE_SID=apex

source_volume_name=apex
mirror_volume_name=apex_mir
snapshot_name=oraprd_post_cycle.1
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
status_file=$log_dir/update_${ORACLE_SID}_status.log
log_file=$log_dir/update_${ORACLE_SID}_qtree.log

#dp 4/Starting update of $ORACLE_SID qtree

>$log_file
>$status_file

####################################################################################################
#####
##### Resync
#####
####################################################################################################
echo "Starting resync command : "`date` >> $log_file
#rsh npnetapp102 snapmirror resync -f $mirror_volume_name
rsh npnetapp102 snapmirror resync -f -S npnetapp102:$source_volume_name npnetapp102:$mirror_volume_name

#
# Run a while loop until expected status is received.
#
mir_status=`rsh npnetapp102 snapmirror status | grep "$mirror_volume_name"`
echo $mir_status
echo $mir_status >> $status_file
mir_status=`echo $mir_status | grep $mirror_volume_name | awk '{print $5}'`
while [ "$mir_status" != "Idle" ]
do
        sleep 15 # 15 Sec interval
        mir_status=`rsh npnetapp102 snapmirror status | grep "$mirror_volume_name"`
        echo "$mir_status"
	echo $mir_status >> $status_file
        mir_status=`echo $mir_status | grep $mirror_volume_name | awk '{print $5}'`
done

echo "Finished resync command : "`date` >> $log_file

####################################################################################################
#####
##### Update
#####
####################################################################################################
echo "Starting update command : "`date` >> $log_file
#rsh npnetapp102 snapmirror update -s hot_backup.1 $mirror_volume_name
rsh npnetapp102 snapmirror update -S npnetapp102:$source_volume_name npnetapp102:$mirror_volume_name

#
# Run a while loop until expected status is received.
#
mir_status=`rsh npnetapp102 snapmirror status | grep "$mirror_volume_name"`
echo $mir_status
echo $mir_status >> $status_file
mir_status=`echo $mir_status | grep $mirror_volume_name | awk '{print $5}'`
while [ "$mir_status" != "Idle" ]
do
        sleep 15 # 15 Sec interval
        mir_status=`rsh npnetapp102 snapmirror status | grep "$mirror_volume_name"`
        echo "$mir_status"
	echo $mir_status >> $status_file
        mir_status=`echo $mir_status | grep $mirror_volume_name | awk '{print $5}'`
done

echo "Finished update command : "`date` >> $log_file

####################################################################################################
#####
##### Make the qtree writeable
#####
####################################################################################################
rsh npnetapp102 snapmirror quiesce $mirror_volume_name
rsh npnetapp102 snapmirror break $mirror_volume_name

#dp 4/Finished update of $ORACLE_SID qtree
