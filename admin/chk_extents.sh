#! /bin/ksh
#
#
dba_dir=/dba/admin
log_dir=${dba_dir}/log
export ORAENV_ASK=NO

db_list=`ps -ef | grep pmon | grep -v "grep pmon" | cut -f3 -d_`

export db_list

for dbname in $db_list
do
#
# Test to see if this is a standby database.
# A standby database is indicated by an S in the /etc/oratab file.
#
standby_test=`grep $dbname /etc/oratab | grep -v S`
if [ "$standby_test" != "" ]
then

	export ORACLE_SID=$dbname
	. /usr/local/bin/oraenv

	log_file=${log_dir}/${ORACLE_SID}_chk_extents.log

	#echo $log_file
	rm $log_file

sqlplus -s "/ as sysdba" << EOF > $log_file
@${dba_dir}/chk_extents.sql
exit;
EOF

	if [ -s $log_file ]
	then
		mail -s 'EXTENT WARNING on '${ORACLE_SID} mcunningham@thedoctors.com < $log_file
		mail -s 'EXTENT WARNING on '${ORACLE_SID} swahby@thedoctors.com < $log_file
	fi
fi

done
