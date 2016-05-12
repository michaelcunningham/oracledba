#!/bin/sh

/usr/local/bin/oracle/make_slot9_usable.sh
chdev -l rmt0 -a block_size=262144 1>>$log_file
mkdir -p /hdb20/restore

sysrestore -f /dev/rmt0 -tD -x -D /hdb20/restore

