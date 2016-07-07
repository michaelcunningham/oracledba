export ORACLE_HOME=/u01/app/oracle/product/12.1.0/client_1
export LD_LIBRARY_PATH=/u01/app/oracle/product/12.1.0/client_1/lib
perl -e 'use DBI; print $DBI::VERSION,"\n";'
perl -e 'use DBD::Oracle; print $DBD::Oracle::VERSION,"\n";'
perl -e 'use DBD::Pg; print $DBD::Pg::VERSION,"\n";'
