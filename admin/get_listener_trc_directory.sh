#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

admin_dir=/mnt/dba/admin
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=$log_dir/${HOST}_${ORACLE_SID}_get_trc.log

listener_cmd=$ORACLE_HOME/bin/lsnrctl
# echo
# echo ".....listener_cmd = "$listener_cmd
# echo

$ORACLE_HOME/bin/lsnrctl << EOF > $log_file
show trc_directory
quit
EOF

trc_directory=`grep trc_directory $log_file | cut -f6 -d" "`
echo $trc_directory
