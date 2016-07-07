# Link to docs
# http://ora2pg.darold.net/documentation.html

# Installed the oracle client while logged in as 'michael' from:
#   /mnt/install/oracle_software/oracle_12cr1_client_x86_64/linuxamd64_12102_client/client

sudo -s
bzip2 -d ora2pg-17.4.tar.bz2
tar xvf ora2pg-17.4.tar

sudo -s
yum install perl-CPAN
# yum install perl-YAML
# yum install perl-ExtUtils-MakeMaker
# cd /mnt/dba/ora2pg/ora2pg-17.4
# perl Makefile.PL
# make && make install
# export ORACLE_HOME=/usr/lib/oracle/12.1/client64
# export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib
# perl -MCPAN -e 'install DBD::Oracle'

export ORACLE_HOME=/home/michael/app/michael/product/12.1.0/client_1
export LD_LIBRARY_PATH=/home/michael/app/michael/product/12.1.0/client_1/lib
perl -MCPAN -e 'install DBD::Oracle'

####################################################################################################
#
# These instructions are for the ol6_ora2pg server installation.
#
####################################################################################################
sudo -s
mkdir /ora2pg
cp /mnt/dba/ora2pg/ora2pg-17.4.tar /ora2pg
cd /ora2pg
tar xvf ora2pg-17.4.tar
rm -f ora2pg-17.4.tar
cd /ora2pg/ora2pg-17.4
perl Makefile.PL
make && make install

yum install perl-YAML

export ORACLE_HOME=/u01/app/oracle/product/12.1.0/client_1
export LD_LIBRARY_PATH=/u01/app/oracle/product/12.1.0/client_1/lib
perl -MCPAN -e 'install DBD::Oracle'
perl -MCPAN -e 'install DBD::Pg'

####################################################################################################
#
# On the server where PostgreSQL is installed this needs to be done
# NOTE: PostgreSQL is installed on an Oracle Linux 7.2 server and the firewall is "on".
#
####################################################################################################
firewall-cmd --add-port 5432/tcp

