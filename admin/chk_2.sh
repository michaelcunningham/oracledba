#! /bin/ksh

#
# The next line will check to see if there are more than 1 listener running with the same name
# If there are then the line returned will look something like
#
#  2 l_orasid
#
results=`ps -ef | grep tnslsnr | grep -v "grep tnslsnr" | awk '{print substr($0,match($0,"/oracle/"),80)}' | awk '{print $2}' | sort | uniq -c | grep -v " 2 "`
echo $results

