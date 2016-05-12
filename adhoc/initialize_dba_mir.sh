#!/bin/sh

new_mir=dba_mir

#
# Start the initializion of the new mirror
#
rsh npnetapp102 snapmirror initialize -S npnetapp102:dba npnetapp102:$new_mir

dp 4/dba_mir initialize started

#
# Run a while loop until expected status is received.
#
mir_status=`rsh npnetapp102 snapmirror status | grep "$new_mir" | awk '{print $5}'`
while [ "$mir_status" != "Idle" ] 
do
        mir_status=`rsh npnetapp102 snapmirror status | grep "$new_mir"`
        echo "$mir_status"
        sleep 15 # 15 Sec interval
        mir_status=`rsh npnetapp102 snapmirror status | grep "$new_mir" | awk '{print $5}'`
done

#rsh npnetapp102 snapmirror quiesce $new_mir
#rsh npnetapp102 snapmirror break $new_mir

dp 4/dba_mir initialize complete
