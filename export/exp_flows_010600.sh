#!/bin/sh

exp flows_files/htmldb@db10 file=/dba/export/dmp/db10_flows_010600.dmp log=/dba/export/log/db10_flows_010600.log \
buffer=20000000 statistics=none feedback=100000

