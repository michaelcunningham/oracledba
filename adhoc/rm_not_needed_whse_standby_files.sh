#! /bin/sh

unset SQLPATH
export ORACLE_SID=+ASM
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

asm_files=`asmcmd ls -ls +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_29/thread_1_seq_104* | awk '{print $12}'`

for this_file in $asm_files
do
#  echo $this_file
  /mnt/dba/adhoc/delete_whse_standby_arch_file.sh +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_29/$this_file
done

# asm_files=`asmcmd ls -ls +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_28/thread_1_seq_10454* | awk '{print $12}'`
# 
# for this_file in $asm_files
# do
# #  echo $this_file
#   /mnt/dba/adhoc/delete_whse_standby_arch_file.sh +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_28/$this_file
# done
# 
# asm_files=`asmcmd ls -ls +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_28/thread_1_seq_10454* | awk '{print $12}'`
# 
# for this_file in $asm_files
# do
# #  echo $this_file
#   /mnt/dba/adhoc/delete_whse_standby_arch_file.sh +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_28/$this_file
# done
# 
# asm_files=`asmcmd ls -ls +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_28/thread_1_seq_10455* | awk '{print $12}'`
# 
# for this_file in $asm_files
# do
#   echo $this_file
#   /mnt/dba/adhoc/delete_whse_standby_arch_file.sh +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_28/$this_file
# done
# 
# asm_files=`asmcmd ls -ls +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_28/thread_1_seq_10456* | awk '{print $12}'`
# 
# for this_file in $asm_files
# do
#   echo $this_file
#   /mnt/dba/adhoc/delete_whse_standby_arch_file.sh +SPINNING_GROUP/WHSEB/ARCHIVELOG/2015_09_28/$this_file
# done
