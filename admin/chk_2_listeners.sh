#! /bin/ksh

#
# The next line will check to see if there are more than 1 listener running with the same name
# If there are then the line returned will look something like
#
#  2 l_orasid
#
#results=`ps -ef | grep tnslsnr | grep -v "grep tnslsnr" | cut -f2 -d- | awk '{print $3}' | sort | uniq -c | grep -v " 1 "`
results=`ps -ef | grep tnslsnr | grep -v "grep tnslsnr" | awk '{print substr($0,match($0,"/oracle/"),80)}' | awk '{print $2}' | sort | uniq -c | grep -v " 1 "`

#
# If the results are positive let's check one more time to make sure
# because sometimes the duplicate listener is stopped automatically.
#
if [ "$results" != "" ]
then
  sleep 10
  results=`ps -ef | grep tnslsnr | grep -v "grep tnslsnr" | awk '{print substr($0,match($0,"/oracle/"),80)}' | awk '{print $2}' | sort | uniq -c | grep -v " 1 "`
fi

#
# If the results are empty then none were found.
#
if [ "$results" = "" ]
then
  exit
fi

#
# Now let's form the message to be text messaged and emailed.
#
listener_count=`echo $results | awk '{print $1}'`
listener_name=`echo $results | awk '{print $2}'`
host=`uname -n`
msg="LISTENER ALERT on "${host}" - "${listener_name}" is duplicated"

dp 4/$msg
dp 3/$msg
echo "" | mail -s "${msg}" mcunningham@thedoctors.com
echo "" | mail -s "${msg}" swahby@thedoctors.com

