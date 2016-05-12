#!/bin/bash
#

# Check for the kernel version
KERN=`uname -r | awk -F. '{ printf("%d.%d\n",$1,$2); }'`

MEM_TOT=`grep MemTotal /proc/meminfo | awk '{print $2}'`
MEM_TOT_MB=`echo $(( $MEM_TOT/1024 ))`

# Find out the HugePage size
HPG_SZ=`grep Hugepagesize /proc/meminfo | awk '{print $2}'`
HPG_MEM=`grep HugePages_Total /proc/meminfo | awk '{print $2}'`
HPG_MEM_MB=`echo $(( $HPG_MEM*($HPG_SZ/1024) ))`

REM_MEM_MB=`echo $(( $MEM_TOT_MB-$HPG_MEM_MB ))`

# Initialize the counters
NUM_PG=0
SHM_SZ=0
SHM_SEGS=0

for SEG_BYTES in `ipcs -m | awk '{print $5}' | grep "[0-9][0-9]*"`
do
   SHM_SZ=`echo $(( $SHM_SZ+$SEG_BYTES ))`
done

SMH_SZ_MB=`echo $(( $SHM_SZ/1024/1024 ))`
SHM_SEGS=`echo $(( $SHM_SZ/($HPG_SZ*1024) ))`
HPG_MIN=`echo $(( $SHM_SEGS+1 ))`
HPG_FREE=`echo $(( $HPG_MEM_MB-$SMH_SZ_MB ))`


echo
echo "*******************************************************************************"
echo
echo "	Total Memory Available on Machine                       = "$MEM_TOT_MB" MB"
echo "	Huge Pages Configured (current vm.nr_hugepages)         = "$HPG_MEM" Pages"
echo "	Huge Page Size (size of memory pages)                   = "$HPG_SZ" KB"
echo
echo "	Huge Memory - Total Available                           = "$HPG_MEM_MB" MB"
echo "	Huge Memory - Currently In Use                          = "$SMH_SZ_MB" MB"
echo "	Huge Memory - Free                             .......  = "$HPG_FREE" MB"
echo
echo "	Remaining Memory (for OS and smaller mem pages)         = "$REM_MEM_MB" MB"
echo
echo "	Shared Memory Segment Size (currently in use)           = "$SMH_SZ_MB" MB"
echo "	Huge Pages Req'd for Shared Memory Segment Size         = "$SHM_SEGS
echo

case $KERN in
   '2.4') HUGETLB_POOL=`echo $(( $NUM_PG*$HPG_SZ/1024 ))`;
          echo "" ;
          echo "	Recommended setting for current usage: vm.hugetlb_pool              = $HUGETLB_POOL" ;;
   '2.6') echo "" ;
          echo "	Recommended setting for current usage: vm.nr_hugepages  = $HPG_MIN" ;;
    *) echo "Unrecognized kernel version $KERN. Exiting." ;;
esac

if [ $HPG_MEM = 0 ]
then
  echo
  echo "	You do not have Huge Pages configured on this machine."
  echo "	If you want to use pages you should configure the"

  case $KERN in
     '2.4') HUGETLB_POOL=`echo $(( $NUM_PG*$HPG_SZ/1024 ))`;
            echo "	/etc/sysctl.conf file with an entry for vm.hugetlb_pool." ;
            echo "	The value should be at least "$HPG_MIN"." ;;
     '2.6') echo "	/etc/sysctl.conf file with an entry for vm.nr_hugepages" ;
            echo "	The value should be at least "$HPG_MIN"." ;;
      *) echo "Unrecognized kernel version $KERN. Exiting." ;;
  esac
fi

if [ $HPG_MEM -gt 0 ]
then
  HGP_OVER_ALLOC=`echo $(( $HPG_MEM-$SHM_SEGS ))`
  HGP_OVER_CNT=`echo $(( ($HGP_OVER_ALLOC*100)/$SHM_SEGS ))`

  if [ $HGP_OVER_CNT -gt 100 ]
  then
    echo
    # echo "	Your Huge Memory Pages are currently over allocated by "$HGP_OVER_CNT" %."
    echo "	You have "$HGP_OVER_CNT"% more huge memory allocated than is required"
    echo "	for the database instances currently running on this machine."
  fi
fi

echo
echo "*******************************************************************************"

# End

