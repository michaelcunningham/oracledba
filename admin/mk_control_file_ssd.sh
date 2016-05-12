#!/bin/sh

. /dba/admin/dba.lib

if [ "$1" = "" ]
then
  echo "Usage: $0 <source db tns> <target db sid>"
  echo "Example: $0 starcpy cprod"
  exit
else
  export SOURCE_TNS=$1
fi

if [ "$2" = "" ]
then
  echo "Usage: $0 <source db tns> <target db sid>"
  echo "Example: $0 starcpy cprod"
  exit
else
  export ORACLE_SID_MASTER=$2
fi

LOGDATE=`date +%a`
controlfile_dir=/dba/admin/ctl
export ORACLE_SID=`get_orasid_from_tns $SOURCE_TNS`

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

DEST_DIR=/${ORACLE_SID_MASTER}

syspwd=`get_sys_pwd $SOURCE_TNS`

#echo $syspwd
#echo "SOURCE_TNS = "$SOURCE_TNS
#echo "ORACLE_SID = "$ORACLE_SID

echo "#########################################################################"
sqlplus -s /nolog <<EOF
connect sys/$syspwd as sysdba
--connect sys/$syspwd@$SOURCE_TNS as sysdba
--connect sys/$syspwd@$SOURCE_TNS
set serveroutput on size 100000
set pages 0
set linesize 200
set termout off
set trimspool on
set trimout on
set feedback off
spool ${controlfile_dir}/${ORACLE_SID_MASTER}_control.sql
prompt startup nomount
prompt create controlfile reuse set database "$2" resetlogs noarchivelog
prompt     maxlogfiles 32
prompt     maxlogmembers 2
prompt     maxdatafiles 100
prompt     maxinstances 8
prompt     maxloghistory 20000
prompt LOGFILE
declare
	--
	-- This pl/sql block creates the LOGFILE section of the backup control file.
	--
	s_out		varchar2(32000);
	n_sql_out_pos	number;
	n_sql_out_len	number;
	b_done		boolean := false;
	CR		varchar2(2) := chr(10);
	function get_log_members( pn_group int ) return varchar2 is
		s_logs		varchar2(200);
		s_member	varchar2(200);
		s_dbname	varchar2(100);
		n_cnt		int := 0;
	begin
		select '/' || lower( name ) into s_dbname from v\$database;
		s_logs := '';
		for r in ( select member from v\$logfile where group# = pn_group ) loop
			--
			-- The ORACLE_SID_MASTER is used in the filename of the redo log.
			-- Do a replace for the ORACLE_SID_MASTER in the redo filename.
			--
			s_member := replace( r.member, substr( s_dbname, 2 ), '$ORACLE_SID_MASTER' );
			--
			-- Now do a replace for directory names with the name of the database.
			--
			s_member := replace( s_member, '/' || s_dbname || '/', '/$DEST_DIR/' );
			if n_cnt > 0 then
				s_logs := s_logs || ',';
			end if;
			s_logs := s_logs || '''';
			s_logs := s_logs || s_member;
			s_logs := s_logs || '''';
			n_cnt := n_cnt + 1;
		end loop;
		return s_logs;
	end;
	function get_logfile_text return varchar2 is
		s_logfile varchar2(32000);
		n_cnt  int := 0;
	begin
		s_logfile := '';
		for r in ( select group#, least( bytes, 268435456 ) bytes from v\$log where group# <= 10 order by group# ) loop
			if n_cnt > 0 then
				s_logfile := s_logfile || ',' || chr(10);
			end if;
			s_logfile := s_logfile || 'group ' || r.group# || ' (';
			s_logfile := s_logfile || get_log_members(r.group#);
			s_logfile := s_logfile || ') size ' || r.bytes;
			n_cnt := n_cnt + 1;
		end loop;
		return s_logfile;
	end;
begin
	s_out := get_logfile_text;
	n_sql_out_pos	:= 1;
	n_sql_out_len	:= 1;
	while not b_done loop
		n_sql_out_len := instr( s_out, CR, n_sql_out_pos ) - n_sql_out_pos;
		if n_sql_out_len < 0 then
			b_done := true;
			n_sql_out_len := length( s_out ) - n_sql_out_pos + 1;
		end if;
		if n_sql_out_len > 255 then
			n_sql_out_len := 255;
		end if;
		dbms_output.put_line( substr( s_out, n_sql_out_pos, n_sql_out_len ) );
		n_sql_out_pos := n_sql_out_pos + n_sql_out_len + 1;
	END LOOP;
end;
/
prompt DATAFILE
declare
	s_out		varchar2(32000);
	b_done		boolean := false;
	n_sql_out_pos	number;
	n_sql_out_len	number;
	CR		varchar2( 2 ) := chr(10);
	function get_data_files return varchar2 is
                s_logs          varchar2(32000);
                s_member        varchar2(50);
                s_dbname        varchar2(100);
                n_cnt           int := 0;
	begin
                select '/' || lower( name ) into s_dbname from v\$database;
		s_logs := '';
		for r in ( select file_name from dba_data_files order by file_id ) loop
                        s_member := replace( r.file_name, s_dbname || '/', '$DEST_DIR' || '/' );
                        s_member := replace( s_member, '/ssd' );
			if n_cnt > 0 then
				s_logs := s_logs || ',' || chr(10);
			end if;
			s_logs := s_logs || '''';
			s_logs := s_logs || s_member;
			s_logs := s_logs || '''';
			n_cnt := n_cnt + 1;
		end loop;
		return s_logs;
	end;
begin
	s_out := get_data_files;
	n_sql_out_pos	:= 1;
	n_sql_out_len	:= 1;
	while not b_done loop
		n_sql_out_len := instr( s_out, CR, n_sql_out_pos ) - n_sql_out_pos;
		if n_sql_out_len < 0 then
			b_done := true;
			n_sql_out_len := length( s_out ) - n_sql_out_pos + 1;
		end if;
		if n_sql_out_len > 255 then
			n_sql_out_len := 255;
		end if;
		dbms_output.put_line( substr( s_out, n_sql_out_pos, n_sql_out_len ) );
		n_sql_out_pos := n_sql_out_pos + n_sql_out_len + 1;
	END LOOP;
end;
/
prompt character set WE8ISO8859P9;;
prompt set autorecovery on
prompt recover database using backup controlfile until cancel
prompt alter database open resetlogs;;

--select	'alter tablespace temp add tempfile '''
--	|| replace( name, (select '/' || lower( name ) from v\$database), '$DEST_DIR' )
--	|| ''' size ' || bytes || ' reuse autoextend off;'
--from	v\$tempfile
--where	file# = 1;

select	'alter tablespace temp add tempfile '''
	|| replace( name, (select '/' || lower( name ) from v\$database), '$DEST_DIR' )
	|| ''' size ' || least( bytes, 4294967296 ) || ' reuse autoextend on next 1g maxsize unlimited;'
from	v\$tempfile
where	file# = 1;

spool off
set termout on
set feedback on
EOF

