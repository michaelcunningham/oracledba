#!/bin/sh

# ps aux | grep ora_pmon | grep -v "grep ora_pmon" | awk '{print $11}' | sort

/dba/admin/listener_log/run_listener_log.sh tdcdv2
/dba/admin/listener_log/run_listener_log.sh tdchst
/dba/admin/listener_log/run_listener_log.sh tdcqa2
/dba/admin/listener_log/gather_stats.sh
