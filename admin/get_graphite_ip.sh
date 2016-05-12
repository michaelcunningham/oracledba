#!/bin/sh

graphite_ip=`cat /etc/tagops/hostinfo | grep ^carbon_vip | cut -d= -f2 | sed "s/\"//g"`
echo $graphite_ip
