#!/bin/sh

# ASM File should = /mnt/dba/logs/+ASM/`hostname -s`_asm_disk_info.txt

grep "+ASM" /etc/oratab > /dev/null
if [ $? -ne 0 ]
then
  echo
  echo "ASM is not on this machine."
  echo
  exit 1
fi

this_asm=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | grep "+ASM"`

# echo $this_asm
unset SQLPATH
export ORACLE_SID=$this_asm
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/+ASM
asm_info_file=${log_dir}/${HOST}_asm_disk_info.txt

#
# Make a list file with ASM information. We will parse it later.
#
sqlplus -s /nolog << EOF > $asm_info_file
connect / as sysdba
set feedback off
set heading off
set pagesize 0
set linesize 200
column dg              format a20
column path            format a80
column total_mb        format 999999999999
column free_mb         format 999999999999
column header_status            format a30
select  nvl2( dg.name,dg.name,'UNUSED' ) dg, d.path,
	d.total_mb, d.free_mb, decode( d.header_status, 'MEMBER', d.header_status || decode( d.state, 'NORMAL', NULL, '/' || d.state ), d.header_status ) status
from	(
	select	*
	from	v\$asm_diskgroup
	) dg, v\$asm_disk d
where   d.group_number = dg.group_number(+)
order by dg, to_number( regexp_replace( d.path, '[^0-9]', '' ) );
exit;
EOF

if [ ! -s "$asm_info_file" ]
then
  # Even though ASM is running on this server it does not have diskgroups mounted.
  # It is probably just for the Oracle Grid installation.
  # Since ASM is not being used, just exit.
  exit
fi

#
# show what storage devices are providing disks to this server.
#
storage_name=`/mnt/dba/admin/get_storage_server_name.sh`
echo
echo
echo "	##############################################################################################################"
echo
echo "	ASM Info File : "$asm_info_file
echo
echo "	Storage devices providing storage to this server are : "$storage_name

for this_dg in `sudo /usr/sbin/vxdg list | sort | egrep -v "NAME|backup" | awk '{print $1}'`
do
  echo
  echo "	** Volume Name : "$this_dg
  echo
  echo "	Block Device  ASM Device                                ASM Diskgroup     Total MB   Free MB  Status"
  echo "	------------  ----------------------------------------  ----------------  --------  --------  ----------------"

  for this_bd in `ls -1 /dev/vx/dsk/$this_dg | sort`
  do
    unset asm_dg
    unset this_asm_device

    this_bd_major=`ls -l /dev/vx/dsk/$this_dg/$this_bd | awk '{print $5}' | sed "s/,//g"`
    this_bd_minor=`ls -l /dev/vx/dsk/$this_dg/$this_bd | awk '{print $6}'`

    # We are in transition from using raw devices to using block devices.
    # First try to see if a raw device is assigned to this block device.
    # If it is, then we will try to see if the block device is being by ASM.
    # If we look and it is not being used by ASM then we will try to see
    # if the block device is being used by ASM.
    # If we can't find a raw device then we will continue by looking to see
    # if ASM is using the block device.

    this_raw_device=`raw -qa 2>&1 | grep -v 'rawctl' | grep "major $this_bd_major," | grep "minor $this_bd_minor$" | cut -d: -f1`
    if [ -n "$this_raw_device" ]
    then
      asm_dg=`grep "$this_raw_device\s" $asm_info_file | awk '{print $1}'`
    fi

    # -n = the length of STRING is nonzero
    # -z = the length of STRING is zero

    if [ -n "$asm_dg" ]
    then
      # this means we found the raw device being used by ASM.
      this_asm_device=$this_raw_device
    else
      # this raw device is not being used by asm, let's try the block device.
      asm_dg=`grep "/dev/vx/dsk/$this_dg/$this_bd\s" $asm_info_file | awk '{print $1}'`
      if [ -n "$asm_dg" ]
      then
        # we found that ASM is using the block device.
        this_asm_device=/dev/vx/dsk/$this_dg/$this_bd
      fi
    fi

    if [ -n "$this_asm_device" ]
    then
      asm_dg=`grep "$this_asm_device\s" $asm_info_file | awk '{print $1}'`
      asm_total_mb=`grep "$this_asm_device\s" $asm_info_file | awk '{print $3}'`
      asm_free_mb=`grep "$this_asm_device\s" $asm_info_file | awk '{print $4}'`
      asm_status=`grep "$this_asm_device\s" $asm_info_file | awk '{print $5}'`
    else
      this_asm_device="No ASM device found."
      unset asm_dg
      unset asm_total_mb
      unset asm_free_mb
      unset asm_status
    fi

    # echo "	"$this_bd"  "$this_bd_major"  "$this_bd_minor"  "$this_asm_device"  "$asm_dg
    # echo "	"$this_bd"  "$this_bd_major"  "$this_bd_minor"  "$this_asm_device"  "$asm_dg"  "$asm_total_mb"  "$asm_free_mb"  "$asm_status

    printf "\t%-12s  %-40s  %-16s  %8s  %8s  %-12s \n" "$this_bd" "$this_asm_device" "$asm_dg" "$asm_total_mb" "$asm_free_mb" "$asm_status"
  done
done

echo
echo "	##############################################################################################################"
echo
echo
