#!/bin/sh

# ps aux | grep ora_pmon | grep -v "grep ora_pmon" | awk '{print $11}' | sort

/dba/admin/listener_log/run_listener_log.sh apex
/dba/admin/listener_log/run_listener_log.sh dwdev
/dba/admin/listener_log/run_listener_log.sh ecmdev
/dba/admin/listener_log/run_listener_log.sh ignite
/dba/admin/listener_log/run_listener_log.sh itqa
/dba/admin/listener_log/run_listener_log.sh stdev
/dba/admin/listener_log/run_listener_log.sh tdcdv3
/dba/admin/listener_log/run_listener_log.sh tdcuat
/dba/admin/listener_log/run_listener_log.sh tdcuat4
/dba/admin/listener_log/gather_stats.sh
