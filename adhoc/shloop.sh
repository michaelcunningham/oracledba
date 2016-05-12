#!/bin/sh

x=0
while [ $x -lt 100000 ]
do
  x=$(($x + 1))
done

echo "seconds = "$x
