#! /bin/ksh

export ORACLE_SID=$1

sqlplus -s /nolog << EOF
set echo off
set heading off
set feedback off
connect / as sysdba
spool /tmp/sequence_chk.txt
select sequence_owner,sequence_name,max_value,last_number from dba_sequences where last_number + (last_number/10) > max_value;
spool off
EOF

test=/tmp/test.txt
file=/tmp/sequence_chk.txt
#[ $# -eq 0 ] && { echo "Usage: $0 filename"; exit 1; }
#[ ! -f "$_file" ] && { echo "Error: $0 file not found."; exit 2; }

if [ ! -s $file ]
then
       #remove the file if it is empty
       rm $file
else      
        # email if file is not empty
       mail -s 'SEQUENCE IS REACHING ITS MAXVALUE' AUddin@thedoctors.com < $file 
       mail -s 'SEQUENCE IS REACHING ITS MAXVALUE' mcunning@thedoctors.com < $file
       mail -s 'SEQUENCE IS REACHING ITS MAXVALUE' SWahby@thedoctors.com < $file
       mail -s 'SEQUENCE IS REACHING ITS MAXVALUE' CAngelov@thedoctors.com < $file
fi

