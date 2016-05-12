#!/bin/bash

####################################################################################################
#
# This script has been designed to run from dbmon04.
#
# DBMON04:/u01/app/oracle/product/10.2:N
# Let's use that to set the environment.

result=`cat /etc/oratab | grep ^DBMON04 | cut -d: -f1`
if [ "$result" != "DBMON04" ]
then
  echo
  echo "	This script is designed to be run from the DBMON04 server."
  echo "	Exiting..."
  echo
fi

export ORACLE_SID=$result

####################################################################################################

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
export HOST=$(hostname -s)

tns=TAGDB
syspwd=admin123

sqlplus -s "system/$syspwd@$tns" << EOF

insert into dc_table_growth(
	table_name, snapshot_time, table_size )
select	segment_name, sysdate, sum(bytes)
from	dba_segments
where	owner = 'TAG'
and	segment_type = 'TABLE'
and	segment_name not like 'BIN\$%'
group by segment_name
union all
select	segment_name, sysdate, sum( bytes )
from	dba_segments
where	owner = 'TAG'
and	segment_type = 'TABLE PARTITION'
and	segment_name not like 'BIN\$%'
group by segment_name;

insert into dc_table_growth_all(
	table_name, snapshot_time, table_size, segment_type )
select	table_name, sysdate, sum(bytes), segment_type
from	(
	select	segment_name table_name, owner, bytes, segment_type
	from	dba_segments
	where	segment_type = 'TABLE'
	union all
	select	segment_name table_name, owner, sum( bytes ) bytes, segment_type
	from	dba_segments
	where	segment_type = 'TABLE PARTITION'
	and	owner = 'TAG'
	group by segment_name, owner, segment_type
	union all
	select	i.table_name, i.owner, s.bytes, s.segment_type
	from	dba_indexes i, dba_segments s
	where	s.segment_name = i.index_name  and   s.owner = i.owner  and   s.segment_type = 'INDEX'
	union all
	select	l.table_name, l.owner, s.bytes, s.segment_type
	from	dba_lobs l, dba_segments s
	where	s.segment_name = l.segment_name  and   s.owner = l.owner  and   s.segment_type = 'LOBSEGMENT'
	union all
	select	l.table_name, l.owner, s.bytes, s.segment_type
	from	dba_lobs l, dba_segments s
	where	s.segment_name = l.index_name  and   s.owner = l.owner  and   s.segment_type = 'LOBINDEX'
	)
where	owner in( 'TAG' )
and	table_name not like 'BIN\$%'
group by segment_type, table_name, owner
order by table_name, sum(bytes) desc;

commit;
exit;
EOF
