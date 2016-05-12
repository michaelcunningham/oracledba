#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 tdcsnp"
  echo
  exit
else
  export ORACLE_SID=$1
fi

if [ ! -d /${ORACLE_SID}/oradata ]
then
  echo
  echo "        Directory "${ORACLE_SID}" not mounted"
  echo "        EXITING PROCESS"
  echo
  exit
fi

if [ ! -d /ssd ]
then
  echo
  echo "        Directory "/ssd" not mounted"
  echo "        EXITING PROCESS"
  echo
  exit
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

#
# Create a file with the names of all the /ssd files
#
data_file_dir=/${ORACLE_SID}/oradata
ssd_data_files=$data_file_dir/${ORACLE_SID}_ssd_data_files.dat

sqlplus -s /nolog << EOF
connect / as sysdba
set heading off
set feedback off
set pagesize 0
set linesize 200
set trimspool on

spool $ssd_data_files

select	ddf.file_name file_name
from	dba_data_files ddf, dba_tablespaces dt
where	ddf.tablespace_name = dt.tablespace_name
and	ddf.file_name like '/ssd/%'
and	dt.contents <> 'TEMPORARY'
union
select	ddf.file_name file_name
from	dba_temp_files ddf, dba_tablespaces dt
where	ddf.tablespace_name = dt.tablespace_name
and	ddf.file_name like '/ssd/%';

spool off
exit;
EOF

#
# Now we need to shutdown the database and copy the /ssd files to the filer.
#
/dba/admin/shutdown_db.sh $ORACLE_SID

ssd_file_list=`cat $ssd_data_files`

for this_ssd_file in $ssd_file_list
do
  this_filer_file=`echo $this_ssd_file | sed "s/\/ssd//g"`
  # echo "this_ssd_file   = "$this_ssd_file
  # echo "this_filer_file = "$this_filer_file
  echo "Copying "$this_ssd_file" ... to ... "$this_filer_file
  cp $this_ssd_file $this_filer_file
done

#
# Now the files are copied to the filer and the database is shutdown.
# This is all this script is intended for.  Another script should take
# over from here and, if necessary, startup the database from the other script.
#
