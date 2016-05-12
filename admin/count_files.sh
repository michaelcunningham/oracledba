#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <directory name>"
  echo
  exit
else
  source_dir=$1
fi

#all_dirs=`ls -lR $source_dir | grep "./" | sed s/://g`
all_dirs=`ls -lR $source_dir | grep \/ | grep -v lrwxrwxrwx | sed s/://g`

for this_dir in $all_dirs
do
  file_count=`ls -l ${this_dir} | wc -l`
  echo $this_dir","$file_count
done
