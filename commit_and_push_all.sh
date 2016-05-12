#!/bin/sh

log_date=`date +%a`
log_dir=/mnt/dba/logs
log_file=${log_dir}/commit_and_push_all_${log_date}.log
git_status_file=${log_dir}/git_status_${log_date}.log

commit_message="Automated git commit and push "`date "+%Y-%m-%d %H:%M"`

cd /mnt/dba
git status > $git_status_file
git add . > $log_file
git commit -m "$commit_message" >> $log_file
git push >> $log_file

mail -s "GIT PUSH LOG FILE" mcunningham@ifwe.co < $log_file
