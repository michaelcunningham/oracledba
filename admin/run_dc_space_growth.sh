#! /bin/sh

. /mnt/dba/admin/dba.lib

#
# For now this script is being run on dbmon04 and it has a /etc/oratab entry that reads
# DBMON04:/u01/app/oracle/product/10.2:N
# Let's use that to set the environment.
#

export PATH=/usr/local/bin:$PATH
export ORACLE_SID=DBMON04
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

for n in `seq 1 8`
do
  tns=PDB0$n
  syspwd=`get_sys_pwd $tns`
  ORACLE_SID=$tns

  sqlplus -s "sys/$syspwd@$tns as sysdba" << EOF
  set serveroutput on
  exec dbms_output.put_line( 'Running on  ' || '$ORACLE_SID' );
  exec sys.dc.space_growth;
exit
EOF
done

for n in `seq 0 9`
do
  tns=TDB0$n
  syspwd=`get_sys_pwd $tns`

  ORACLE_SID=$tns
  sqlplus -s "sys/$syspwd@$tns as sysdba" << EOF
  set serveroutput on
  exec dbms_output.put_line( 'Running on  ' || '$ORACLE_SID' );
  exec sys.dc.space_growth;
exit
EOF
done

for n in `seq 10 63`
do
  tns=TDB$n
  syspwd=`get_sys_pwd $tns`

  ORACLE_SID=$tns
  sqlplus -s "sys/$syspwd@$tns as sysdba" << EOF
  set serveroutput on
  exec dbms_output.put_line( 'Running on  ' || '$ORACLE_SID' );
  exec sys.dc.space_growth;
exit
EOF
done


for n in `seq 1 2`
do
  tns=MMDB0$n
  syspwd=`get_sys_pwd $tns`

  ORACLE_SID=$tns
  sqlplus -s "sys/$syspwd@$tns as sysdba" << EOF
  set serveroutput on
  exec dbms_output.put_line( 'Running on  ' || '$ORACLE_SID' );
  exec sys.dc.space_growth;
exit
EOF
done

tns=TAGDB
syspwd=`get_sys_pwd $tns`

ORACLE_SID=$tns
sqlplus -s "sys/$syspwd@$tns as sysdba" << EOF
set serveroutput on
exec dbms_output.put_line( 'Running on  ' || '$ORACLE_SID' );
exec sys.dc.space_growth;
exit
EOF

tns=WHSE
syspwd=`get_sys_pwd $tns`

ORACLE_SID=$tns
sqlplus -s "sys/$syspwd@$tns as sysdba" << EOF
set serveroutput on
exec dbms_output.put_line( 'Running on  ' || '$ORACLE_SID' );
exec sys.dc.space_growth;
exit
EOF
