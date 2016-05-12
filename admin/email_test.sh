#!/bin/sh

log_file=/dba/admin/log/email_test.txt
echo "Test subject line" > $log_file

# mail -s 'EMAIL TEST' mcunningham@thedoctors.com < $log_file
mail -s 'EMAIL TEST' `cat /dba/admin/dba_team` < $log_file
