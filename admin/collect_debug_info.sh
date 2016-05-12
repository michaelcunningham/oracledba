sqlplus -prelim / as sysdba <<EOF
--Debug info
oradebug setmypid
oradebug unlimit
oradebug hanganalyze 3
oradebug dump ashdumpseconds 30
oradebug dump systemstate 266
oradebug tracefile_name
--wait 90 seconds then run again
oradebug hanganalyze 3
EOF
