#!/bin/sh

host=`hostname | cut -d. -f1`

if [ "$host" = "npdb570" ]
then
  /dba/admin/listener_log/run_listener_log.sh novadev
else
  ssh npdb570 /dba/admin/listener_log/run_listener_log.sh novadev
fi

# /dba/admin/listener_log/gather_stats.sh
