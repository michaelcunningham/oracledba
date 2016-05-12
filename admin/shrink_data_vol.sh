#!/bin/sh

# archive_lag=`expr $primary_test_prod - $standby_test_prod`

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <filesystem> <max_used_percentage>"
  echo
  echo "   Example: $0 tdcdw 0.9"
  echo
  exit
fi

chk_vol="$1"
new_pct="$2"

filer_name=`df -P -m | grep $chk_vol\$ | cut -d: -f1 | uniq`
if [ "$filer_name" = "" ]
then
  echo
  echo "   Filer was not found for the volume provided."
  echo
  exit
fi

total_size=`df -P -m | grep ${chk_vol}$ | awk '{sub(/MB/,"");print$2}'`
used_size=`df -P -m | grep ${chk_vol}$ | awk '{sub(/MB/,"");print$3}'`
avail_size=`df -P -m | grep ${chk_vol}$ | awk '{sub(/MB/,"");print$4}'`
pct_used=`df -P -m | grep ${chk_vol}$ | awk '{sub(/%/,"");print$5}'`

total_size=`expr $total_size / 1000`
used_size=`expr $used_size / 1000`
avail_size=`expr $avail_size / 1000`

# The [ test statement can't accept decimals - only integers
# so we do some math here to make the values we sent in look
# like integers by multiplying by 100.
new_pct_100=`echo "$new_pct * 100" | bc | cut -d. -f1`

if [ "$new_pct_100" -ge "100" ]
then
  echo
  echo "   Wrong size."
  echo
  exit
fi

if [ "$total_size" -lt "50" ]
then
  echo
  echo "   The volume is less than 50GB so we aren't going to change the size."
  echo
  exit
fi

#new_pct=0.8
new_size_work=`echo $used_size / $new_pct | bc`
temp_var1=`expr $new_size_work % 10`
temp_var2=`expr 10 - $temp_var1`
new_size=`expr $new_size_work + $temp_var2`

echo "filer_name  "$filer_name
echo "total_size  "$total_size
echo "used_size   "$used_size
echo "avail_size  "$avail_size
echo "new_pct     "$new_pct
echo "new_size    "$new_size
echo "pct_used    "$pct_used
echo "temp_var1   "$temp_var1
echo "temp_var2   "$temp_var2

#
# At this point we know the new_size the volume should be to bring it closer to 80 percent.
# Let's change the size of the volume.
#
rsh $filer_name vol size $chk_vol ${new_size}g

