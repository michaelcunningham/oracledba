#!/bin/bash


ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora24 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh UTLDB
