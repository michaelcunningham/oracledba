#!/bin/sh

####################################################################
# npnetapp108
filer_info=`rsh npnetapp108 df -Ag | grep -v snapshot | grep aggr0`
echo
echo NPNETAPP108
echo "Capacity	aggr0	"`echo $filer_info | awk '{print $5}'`

filer_info=`rsh npnetapp108 df -Ag | grep -v snapshot | grep aggr1`
echo "Capacity	aggr1	"`echo $filer_info | awk '{print $5}'`

####################################################################
# npnetapp109
filer_info=`rsh npnetapp109 df -Ag | grep -v snapshot | grep aggr0`
echo
echo NPNETAPP109
echo "Capacity	aggr0	"`echo $filer_info | awk '{print $5}'`

filer_info=`rsh npnetapp109 df -Ag | grep -v snapshot | grep aggr1`
echo "Capacity	aggr1	"`echo $filer_info | awk '{print $5}'`

filer_info=`rsh npnetapp109 df -Ag | grep -v snapshot | grep aggr2`
echo "Capacity	aggr2	"`echo $filer_info | awk '{print $5}'`

####################################################################
# npnetapp103
filer_info=`rsh npnetapp103 df -Ag | grep -v snapshot | grep aggr0`
echo
echo NPNETAPP103
echo "Capacity	aggr0	"`echo $filer_info | awk '{print $5}'`

filer_info=`rsh npnetapp103 df -Ag | grep -v snapshot | grep aggr1`
echo "Capacity	aggr1	"`echo $filer_info | awk '{print $5}'`

####################################################################
# npnetapp104
filer_info=`rsh npnetapp104 df -Ag | grep -v snapshot | grep aggr0`
echo
echo NPNETAPP104
echo "Capacity	aggr0	"`echo $filer_info | awk '{print $5}'`

filer_info=`rsh npnetapp104 df -Ag | grep -v snapshot | grep aggr1`
echo "Capacity	aggr1	"`echo $filer_info | awk '{print $5}'`


#rsh npnetapp109 df -Ag | grep -v snapshot
#rsh npnetapp103 df -Ag | grep -v snapshot
#rsh npnetapp104 df -Ag | grep -v snapshot
