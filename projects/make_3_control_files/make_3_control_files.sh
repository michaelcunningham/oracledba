#! /bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 TDB01"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

#
# Create a file with the names of the controlfiles.
#
dir_file=/mnt/dba/projects/make_3_control_files/logs/${ORACLE_SID}_control_file_dir.txt
work_file=/mnt/dba/projects/make_3_control_files/logs/${ORACLE_SID}_control_file_name.txt
rcv_file=/mnt/dba/projects/make_3_control_files/logs/${ORACLE_SID}_make_3_control_files.rcv

sqlplus -s /nolog << EOF > $dir_file
connect / as sysdba
set pagesize 0
set heading off
set feedback off
set verify off
set echo off
select substr( name, 1, instr( replace( name, 'CONTROLFILE/' ), '/', -1 )-1 ) from v\$controlfile order by name fetch first 1 rows only;
exit;
EOF

sqlplus -s /nolog << EOF > $work_file
connect / as sysdba
set pagesize 0
set heading off
set feedback off
set verify off
set echo off
select name from v\$controlfile order by name fetch first 1 rows only;
exit;
EOF

#
# Make the rcv file that will be used by RMAN to create 3 control files.
#
echo "run" > $rcv_file
echo "{" >> $rcv_file

ctl_dir=`cat $dir_file`
ctl_file=`cat $work_file`
control_files="alter system set control_files="

new_file=$ctl_dir/control01.ctl
echo "restore controlfile to '$new_file' from '$ctl_file';" >> $rcv_file
control_files=${control_files}"'"${new_file}"'"
new_file=$ctl_dir/control02.ctl
echo "restore controlfile to '$new_file' from '$ctl_file';" >> $rcv_file
control_files=${control_files},"'"${new_file}"'"
new_file=$ctl_dir/control03.ctl
echo "restore controlfile to '$new_file' from '$ctl_file';" >> $rcv_file
control_files=${control_files},"'"${new_file}"' scope=spfile;"

echo "}" >> $rcv_file

cat $rcv_file
echo $control_files

sqlplus -s /nolog << EOF
connect / as sysdba
$control_files
create pfile from spfile;
exit;
EOF

rman target / << EOF
shutdown immediate
startup nomount
@$rcv_file
alter database mount;
alter database open;
quit
EOF
