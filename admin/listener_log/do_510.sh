#!/bin/sh

# ps aux | grep ora_pmon | grep -v "grep ora_pmon" | awk '{print $11}' | sort

/dba/admin/listener_log/run_listener_log.sh itdv
/dba/admin/listener_log/run_listener_log.sh ituat
/dba/admin/listener_log/run_listener_log.sh novadev
/dba/admin/listener_log/run_listener_log.sh tdccpy
/dba/admin/listener_log/run_listener_log.sh tdcdv4
/dba/admin/listener_log/run_listener_log.sh tdcdv6
/dba/admin/listener_log/run_listener_log.sh tdcdv7
/dba/admin/listener_log/run_listener_log.sh tdcroqa
/dba/admin/listener_log/gather_stats.sh
