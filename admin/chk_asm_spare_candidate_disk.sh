#!/bin/sh

#
# We don't want to worry about dev servers so if this is a known dev server
# just exit.
#
hostname -s | egrep "dora|sora" > /dev/null
if [ $? -eq 0 ]
then
  exit
fi

grep "+ASM" /etc/oratab > /dev/null
if [ $? -ne 0 ]
then
  # ASM is not on this machine, just exit.
  exit 1
fi

#
# Make a list file with ASM information. We will parse it later.
#
unset SQLPATH
export ORACLE_SID=+ASM
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
asm_info_file=${log_dir}/${HOST}_chk_asm_spare_candidate_disk.txt
block_info_file=${log_dir}/${HOST}_raw_disk_info.txt
email_body_file=${log_dir}/${HOST}_chk_asm_spare_candidate_disk.email

EMAILDBA=dba@tagged.com

#
# Create a text file with a list of CANDIDATE disks as reported by ASM.
#
sqlplus -s /nolog << EOF > $asm_info_file
connect / as sysdba
set feedback off
set heading off
set pagesize 0
set linesize 150
column path		format a30
column header_status	format a30
select	d.path, d.header_status
from	v\$asm_disk d
where	d.header_status = 'CANDIDATE'
order by d.path;
exit;
EOF

if [ ! -s $asm_info_file ]
then
  # echo "There are no candidate disks. Send an email."
  echo "" > $email_body_file
  echo "" >> $email_body_file
  echo "################################################################################" >> $email_body_file
  echo "" >> $email_body_file
  echo 'This report created by : '$0 >> $email_body_file
  echo "" >> $email_body_file
  echo "################################################################################" >> $email_body_file
  echo "" >> $email_body_file

  mail -s "WARNING: No ASM CANDIDATE disks available on $HOST" $EMAILDBA < $email_body_file
  exit
fi

> $block_info_file

#
# Create a parsable file with information about the VX diskgroupgs and disks.
#
for this_dg in `sudo /usr/sbin/vxdg list | sort | egrep -v "NAME|backup" | awk '{print $1}'`
do
  for this_bd in `ls -1 /dev/vx/dsk/$this_dg | sort`
  do
    this_bd_major=`ls -l /dev/vx/dsk/$this_dg/$this_bd | awk '{print $5}' | sed "s/,//g"`
    this_bd_minor=`ls -l /dev/vx/dsk/$this_dg/$this_bd | awk '{print $6}'`

    echo $this_dg"	"$this_bd"	"$this_bd_major"	"$this_bd_minor >> $block_info_file
  done
done

#
# Now we need to loop through the data and verify that the CANDIDATE disk in on a DATA volume.
# It won't do us any good if it is on a LOG volume.
#
for this_path in `cat $asm_info_file | awk '{print $1}'`
do
  this_raw_device=`raw -qa | grep $this_path:`
  this_path_major=`echo $this_raw_device | awk '{print $5}' | sed "s/,//g"`
  this_path_minor=`echo $this_raw_device | awk '{print $7}'`

  this_diskgroup=`awk '($3 == "'$this_path_major'") && ($4 == "'$this_path_minor'") {print $1}' ${block_info_file}`
  this_block_device=`awk '($3 == "'$this_path_major'") && ($4 == "'$this_path_minor'") {print $2}' ${block_info_file}`

  # echo
  # echo "	$this_path"
  # echo "	$this_raw_device"
  # echo "	$this_path_major"
  # echo "	$this_path_minor"
  # echo "	$this_diskgroup"
  # echo "	$this_block_device"

  # TESTING
  # this_diskgroup=tdb01dh1

  result=`echo $this_diskgroup | grep data`

  # echo "	$result"

  if [ "$result" = "$this_diskgroup" ]
  then
    # This device in on a DATA volume. We are good, so exit.
    # echo
    # echo "This CANDIDATE disk is on a DATA volume."
    # echo
    exit
  fi

  # We tried the easy way, now we have to do more work to see if this is a DATA volume.
  dg_text=`echo $this_diskgroup | sed "s/[0-9]\{1,2\}$//g"`
  dg_text=`echo $dg_text | awk '{print substr($0,1,length-1)}'`
  result=`echo $dg_text | awk '{print substr($0,length)}'`

  # echo "	$result"

  if [ "$result" = "d" ]
  then
    # This device in on a DATA volume. We are good, so exit.
    # echo
    # echo "This CANDIDATE disk is on a DATA volume."
    # echo
    exit
  fi

done

#
# If we got this far there are no CANDIDATE disks available on a DATA volume.
# Send an email.
#
echo "" > $email_body_file
echo "" >> $email_body_file
echo "################################################################################" >> $email_body_file
echo "" >> $email_body_file
echo 'This report created by : '$0 >> $email_body_file
echo "" >> $email_body_file
echo "################################################################################" >> $email_body_file
echo "" >> $email_body_file

mail -s "WARNING: No ASM CANDIDATE disks available on $HOST" $EMAILDBA < $email_body_file
