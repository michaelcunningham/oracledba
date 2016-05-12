#!/bin/sh

export ORACLE_SID=itdev

exp \"/ as sysdba\" file=/dba/export/dmp/itdev_full.dmp log=/dba/export/log/itdev_full.log full=y buffer=10000000 statistics=none

dp 4/ITDEV export complete
