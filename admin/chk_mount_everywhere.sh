#!/bin/bash

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <mount point to check>"
  echo
  echo "	Example: $0 novadev"
  echo
  exit
else
  export mount_point=$1
fi

# df -P -m | sed "s/1048576-blocks/MB_blocks/g" | sed "s/Capacity/%Used/g" | awk '{printf("%-45s  %-s\n", $1,$6)}' | grep $mount_point

echo
echo "Checking NPDB100 ..."
echo
ssh npdb100 df -P -m | sed "s/1048576-blocks/MB_blocks/g" | sed "s/Capacity/%Used/g" | awk '{printf("%-45s  %-s\n", $1,$6)}' | grep "${mount_point}$\|${mount_point}arch"

echo
echo "Checking NPDB110 ..."
echo
ssh npdb110 df -P -m | sed "s/1048576-blocks/MB_blocks/g" | sed "s/Capacity/%Used/g" | awk '{printf("%-45s  %-s\n", $1,$6)}' | grep "${mount_point}$\|${mount_point}arch"

echo
echo "Checking NPDB510 ..."
echo
ssh npdb510 df -P -m | sed "s/1048576-blocks/MB_blocks/g" | sed "s/Capacity/%Used/g" | awk '{printf("%-45s  %-s\n", $1,$6)}' | grep "${mount_point}$\|${mount_point}arch"

echo
echo "Checking NPDB520 ..."
echo
ssh npdb520 df -P -m | sed "s/1048576-blocks/MB_blocks/g" | sed "s/Capacity/%Used/g" | awk '{printf("%-45s  %-s\n", $1,$6)}' | grep "${mount_point}$\|${mount_point}arch"

echo
echo "Checking NPDB530 ..."
echo
ssh npdb530 df -P -m | sed "s/1048576-blocks/MB_blocks/g" | sed "s/Capacity/%Used/g" | awk '{printf("%-45s  %-s\n", $1,$6)}' | grep "${mount_point}$\|${mount_point}arch"

echo
echo "Checking NPDB550 ..."
echo
ssh npdb550 df -P -m | sed "s/1048576-blocks/MB_blocks/g" | sed "s/Capacity/%Used/g" | awk '{printf("%-45s  %-s\n", $1,$6)}' | grep "${mount_point}$\|${mount_point}arch"

echo
echo "Checking NPDB570 ..."
echo
ssh npdb570 df -P -m | sed "s/1048576-blocks/MB_blocks/g" | sed "s/Capacity/%Used/g" | awk '{printf("%-45s  %-s\n", $1,$6)}' | grep "${mount_point}$\|${mount_point}arch"

