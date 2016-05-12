#!/bin/sh

# grep "+ASM" /etc/oratab > /dev/null
ps x | grep -v grep | grep pmon_+ASM > /dev/null
if [ $? -ne 0 ]
then
  # ASM is not on this machine, just exit.
  exit 1
fi

unset SQLPATH
export ORACLE_SID=+ASM
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${HOST}_chk_asm_pct.log
EMAILDBA=dba@tagged.com
PAGEDBA=dbaoncall@tagged.com

> $log_file

#
# Check all diskgroups to see if they are below a graduated threshold for pct free.
#

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba
set feedback off
set linesize 100
set serveroutput on

declare
	n_pct_free_threshold	number;
	n_mb_free_threshold	number;
	n_TB			number := 1099511627776;
	b_header_printed	boolean := false;
	s_output		varchar2(200);
begin
	for r in(
		select	name, total_mb*1024*1024 total_bytes, total_mb,
			total_mb - free_mb used_mb, free_mb,
			to_char( ( ( total_mb - free_mb ) / total_mb ) * 100, '990.00' ) pct_used,
			to_char( ( free_mb / total_mb ) * 100, '990.00' ) pct_free
		from	v\$asm_diskgroup
		where	state = 'MOUNTED'
		)
	loop
		if r.total_bytes < n_TB * 1 then
			n_pct_free_threshold := 10.0;
			n_mb_free_threshold := 90 * 1024;
		elsif r.total_bytes < n_TB * 2 then
			n_pct_free_threshold := 6.0;
			n_mb_free_threshold := 90 * 1024;
		elsif r.total_bytes < n_TB * 3 then
			n_pct_free_threshold := 4.0;
			n_mb_free_threshold := 120 * 1024;
		elsif r.total_bytes < n_TB * 4 then
			n_pct_free_threshold := 3.0;
			n_mb_free_threshold := 120 * 1024;
		elsif r.total_bytes < n_TB * 5 then
			n_pct_free_threshold := 2.5;
			n_mb_free_threshold := 150 * 1024;
		else
			n_pct_free_threshold := 2.0;
			n_mb_free_threshold := 150 * 1024;
		end if;


		if ( r.pct_free < n_pct_free_threshold ) or ( r.free_mb < n_mb_free_threshold ) then
			if b_header_printed = false then
				dbms_output.put_line( 'Diskgroup Name              Total (MB)     Used (MB)     Free (MB)   Used%   Free%' );
				dbms_output.put_line( '------------------------  ------------  ------------  ------------  ------  ------' );
				b_header_printed := true;
			end if;

			s_output := rpad( r.name, 24 );
			s_output := s_output || lpad( to_char( r.total_mb, '999,999,999' ), 14 );
			s_output := s_output || lpad( to_char( r.used_mb, '999,999,999' ), 14 );
			s_output := s_output || lpad( to_char( r.free_mb, '999,999,999' ), 14 );
			s_output := s_output || lpad( to_char( r.pct_used, '990.00' ), 8 );
			s_output := s_output || lpad( to_char( r.pct_free, '990.00' ), 8 );
			dbms_output.put_line( s_output );
		end if;
	end loop;
end;
/

exit;
EOF

#
# If there is a log file then there was either an error with the script
# or, at least, one diskgroup that is beyond the threshold.
# Check to see if it was an error or if space needs to be added.
#
if [ -s $log_file ]
then
  cat $log_file | grep "ORA-" > /dev/null
  if [ $? -eq 0 ]
  then
    mail_subj="WARNING: ASM PCT Check Failed"
  else
    mail_subj="WARNING: ASM threshold low on $HOST"
    addspace=true
  fi
  mail -s "$mail_subj" $EMAILDBA < $log_file
fi
