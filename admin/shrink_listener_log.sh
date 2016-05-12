#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 dwprd"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

#listener_cmd=`ps -ef | grep l_${ORACLE_SID} | grep tnslsnr | awk '{print $8}'`
listener_cmd=`ps -eo "%a" | grep "l_${ORACLE_SID} " | grep tnslsnr | awk '{print $1}'`
# echo
# echo ".....listener_cmd = "$listener_cmd
# echo

listener_cmd=`echo $listener_cmd | sed s/tnslsnr/lsnrctl/g`
# echo
# echo ".....listener_cmd = "$listener_cmd
# echo

listener_log_file=`${listener_cmd} status l_${ORACLE_SID} | grep "Listener Log File" | awk '{print $4}'`
echo
echo ".....listener_log_file = "$listener_log_file
echo

listener_log_dir=`dirname $listener_log_file`
echo
echo ".....listener_log_dir = "$listener_log_dir
echo

rm ${listener_log_file}.5
mv ${listener_log_file}.4 ${listener_log_file}.5
mv ${listener_log_file}.3 ${listener_log_file}.4
mv ${listener_log_file}.2 ${listener_log_file}.3
mv ${listener_log_file}.1 ${listener_log_file}.2
cp ${listener_log_file} ${listener_log_file}.1
> ${listener_log_file}


listener_trace_log_dir=`/dba/admin/get_listener_trc_directory.sh $ORACLE_SID`
listener_trace_log_file=$listener_trace_log_dir/l_$ORACLE_SID.log

echo
echo ".....listener_trace_log_file = "$listener_trace_log_file
echo

rm ${listener_trace_log_file}.5
mv ${listener_trace_log_file}.4 ${listener_trace_log_file}.5
mv ${listener_trace_log_file}.3 ${listener_trace_log_file}.4
mv ${listener_trace_log_file}.2 ${listener_trace_log_file}.3
mv ${listener_trace_log_file}.1 ${listener_trace_log_file}.2
cp ${listener_trace_log_file} ${listener_trace_log_file}.1
> ${listener_trace_log_file}

