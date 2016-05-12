#! /bin/sh

unset SQLPATH
export ORACLE_SID=TDB24
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

log_file=/mnt/dba/projects/DBA-333/logs/start_object_count_TDB24.txt

export ORACLE_SID=TDB24

sqlplus -s /nolog << EOF > $log_file
connect tag/zx6j1bft

set linesize 100

column tablespace_name format a40
column obj_count format 999,999

select	tablespace_name, count(*) obj_count
from	dba_segments
where	owner = 'TAG'
and	segment_name not like 'BIN$%'
and     tablespace_name like '%TBS'
group by tablespace_name
order by tablespace_name;

exit;
EOF

export ORACLE_SID=TDB25

sqlplus -s /nolog << EOF >> $log_file
connect tag/zx6j1bft

set linesize 100
set pagesize 0

column tablespace_name format a40
column obj_count format 999,999

select	tablespace_name, count(*) obj_count
from	dba_segments
where	owner = 'TAG'
and	segment_name not like 'BIN$%'
and     tablespace_name like '%TBS'
group by tablespace_name
order by tablespace_name;

exit;
EOF

export ORACLE_SID=TDB26

sqlplus -s /nolog << EOF >> $log_file
connect tag/zx6j1bft

set linesize 100
set pagesize 0

column tablespace_name format a40
column obj_count format 999,999

select	tablespace_name, count(*) obj_count
from	dba_segments
where	owner = 'TAG'
and	segment_name not like 'BIN$%'
and     tablespace_name like '%TBS'
group by tablespace_name
order by tablespace_name;

exit;
EOF

export ORACLE_SID=TDB27

sqlplus -s /nolog << EOF >> $log_file
connect tag/zx6j1bft

set linesize 100
set pagesize 0

column tablespace_name format a40
column obj_count format 999,999

select	tablespace_name, count(*) obj_count
from	dba_segments
where	owner = 'TAG'
and	segment_name not like 'BIN$%'
and     tablespace_name like '%TBS'
group by tablespace_name
order by tablespace_name;

exit;
EOF

export ORACLE_SID=TDB28

sqlplus -s /nolog << EOF >> $log_file
connect tag/zx6j1bft

set linesize 100
set pagesize 0

column tablespace_name format a40
column obj_count format 999,999

select	tablespace_name, count(*) obj_count
from	dba_segments
where	owner = 'TAG'
and	segment_name not like 'BIN$%'
and     tablespace_name like '%TBS'
group by tablespace_name
order by tablespace_name;

exit;
EOF

export ORACLE_SID=TDB29

sqlplus -s /nolog << EOF >> $log_file
connect tag/zx6j1bft

set linesize 100
set pagesize 0

column tablespace_name format a40
column obj_count format 999,999

select	tablespace_name, count(*) obj_count
from	dba_segments
where	owner = 'TAG'
and	segment_name not like 'BIN$%'
and     tablespace_name like '%TBS'
group by tablespace_name
order by tablespace_name;

exit;
EOF

export ORACLE_SID=TDB30

sqlplus -s /nolog << EOF >> $log_file
connect tag/zx6j1bft

set linesize 100
set pagesize 0

column tablespace_name format a40
column obj_count format 999,999

select	tablespace_name, count(*) obj_count
from	dba_segments
where	owner = 'TAG'
and	segment_name not like 'BIN$%'
and     tablespace_name like '%TBS'
group by tablespace_name
order by tablespace_name;

exit;
EOF

export ORACLE_SID=TDB31

sqlplus -s /nolog << EOF >> $log_file
connect tag/zx6j1bft

set linesize 100
set pagesize 0

column tablespace_name format a40
column obj_count format 999,999

select	tablespace_name, count(*) obj_count
from	dba_segments
where	owner = 'TAG'
and	segment_name not like 'BIN$%'
and     tablespace_name like '%TBS'
group by tablespace_name
order by tablespace_name;

exit;
EOF

echo > $log_file.1
cat $log_file | sed "/^$/d" >> $log_file.1
mv $log_file.1 $log_file

total_count=0
for i in `cat $log_file | awk '{print $2}' | grep "^[0-9]"`
do
  total_count=$((total_count + $i))
done

echo >> $log_file
echo "Total Count                                   "$total_count >> $log_file
echo >> $log_file
cat $log_file
