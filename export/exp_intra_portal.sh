orabin_dir=/usr/local/bin/oracle
oraid_user_file=${orabin_dir}/oraid_user

tns=itprd
username=intra_portal
userpwd=`cat ${oraid_user_file} | awk '$3$4 ~ /itprdintra_portal/ {print $5}'`

dmp_dir=/u01/export/dmp
log_dir=/u01/export/log
file_base=${username}_`date +%Y%m%d`
dmp_file=${dmp_dir}/${file_base}.dmp
log_file=${log_dir}/${file_base}.log

exp ${username}/${userpwd}@${tns} file=${dmp_file} log=${log_file}

results=`tail -1 ${log_file} | grep "without warnings"`
if [ "$results" = "" ]
then
  return 1
else
  return 0
fi
