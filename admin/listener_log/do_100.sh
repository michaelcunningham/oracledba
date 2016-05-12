#!/bin/sh

# ps aux | grep ora_pmon | grep -v "grep ora_pmon" | awk '{print $11}' | sort

/dba/admin/listener_log/run_listener_log.sh iris
#/dba/admin/listener_log/run_listener_log.sh oemprd
/dba/admin/listener_log/run_listener_log.sh stprd
/dba/admin/listener_log/run_listener_log.sh tdcgld
/dba/admin/listener_log/run_listener_log.sh tdcprd
/dba/admin/listener_log/run_listener_log.sh tdcrt

/dba/admin/listener_log/run_listener_log.sh stprd2
/dba/admin/listener_log/run_listener_log.sh tdc247
/dba/admin/listener_log/gather_stats.sh
