#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 orcl"
  echo
  exit
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect / as sysdba
set serveroutput on

begin
        for r in (
                select  'alter system disconnect session '''
                        || sid || ',' || serial# || ''' immediate' sql_text
                from    v\$session
                where   username = 'RMAN' )
        loop
                dbms_output.put_line( r.sql_text );
                execute immediate r.sql_text;
        end loop;
end;
/

drop user rman cascade;

create user rman identified by rman
default tablespace rman
quota unlimited on rman;

grant recovery_catalog_owner to rman;

exit;
EOF
