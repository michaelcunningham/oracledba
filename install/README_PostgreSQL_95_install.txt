#
# First, install the RPM that will create file: /etc/yum.repos.d/pgdg-95-oraclelinux.repo
#

rpm -ivh https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-6-x86_64/pgdg-oraclelinux95-9.5-2.noarch.rpm

#
# Next, install the PostgreSQL 9.5 server
#
yum install postgresql95-server
