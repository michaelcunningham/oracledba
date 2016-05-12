#!/bin/sh

# ps aux | grep ora_pmon | grep -v "grep ora_pmon" | awk '{print $11}' | sort

/dba/admin/listener_log/run_listener_log.sh dwprd
/dba/admin/listener_log/run_listener_log.sh dwqa
/dba/admin/listener_log/run_listener_log.sh ecmprd
/dba/admin/listener_log/run_listener_log.sh itprod
/dba/admin/listener_log/run_listener_log.sh tdcro
/dba/admin/listener_log/gather_stats.sh
