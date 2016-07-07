#!/bin/sh

export ORACLE_HOME=/home/michael/app/michael/product/12.1.0/client_1
export ORACLE_DSN=dbi:Oracle:host=192.168.56.101:sid=fmd
export ORACLE_USER=tag
export ORACLE_PWD=zx6j1bft

# USER_GRANTS
#   0 = If you login as a user with DBA privs
#   1 = If you login as a normal user (meaning you cannot query DBA_* views)
# export USER_GRANTS=

# export EXPORT_SCHEMA=
