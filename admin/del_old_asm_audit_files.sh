#!/bin/sh

# This file delete old audit log files from /u01/app/12.1.0.1/grid/rdbms/audit

# We want to make sure only one instance of this command is running.
# Check to see if any others are running.
# If there are, then exit.

this_filename=`basename $0`

#
# The next statement checks to make sure the script is not already running.
# We don't want to have it running in multiple processes.
#
if pgrep -f "^/bin/sh [^ ]*/$this_filename" | grep -q -v "^$$\$" ; then
   exit
fi
  
if [ -d /u01/app/12.1.0.1/grid/rdbms/audit ]
then
  /usr/bin/find /u01/app/12.1.0.1/grid/rdbms/audit -name '\+ASM*.aud' -mmin +10 -delete
fi
