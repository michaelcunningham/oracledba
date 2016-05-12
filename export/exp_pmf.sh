#!/bin/sh

exp dwowner/dwowner@tdcdw file=/dba/export/dmp/tdcdw_policy_monthly_fact.dmp log=/dba/export/log/tdcdw_policy_monthly_fact.log \
buffer=20000000 statistics=none feedback=100000 tables=policy_monthly_fact

