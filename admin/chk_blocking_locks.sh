#!/bin/sh

####################################################################################################
#
# This script is intended to be run in the cron and can run each minute using the following.
#
#	* * * * * /dba/admin/chk_blocking_locks.sh $ORACLE_SID 1>/dev/null 2>/dev/null
#
####################################################################################################

#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_chk_blocking_locks.log
email_body_file=${log_dir}/${ORACLE_SID}_chk_blocking_locks.email
mkdir -p $log_dir

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

EMAILDBA=dba@ifwe.co

#
# Check to make sure the database is running.
# We don't want false emails if the database is not available.
#
/mnt/dba/admin/chk_db_status.sh $ORACLE_SID
result=$?
if [ "$result" != "0" ]
then
  exit
fi

#
# Check to see if a blocking lock exists
#
blocking_lock_exist=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select	holding_session, waiting_session, lock_type,
	mode_requested, lock_id1, lock_id2
from	dba_waiters;
exit;
EOF`

blocking_lock_exist=`echo $blocking_lock_exist`

if [ "$blocking_lock_exist" = "" ]
then
  # No blocking locks exist.  Just exit.
  exit
fi

sqlplus -s /nolog << EOF > $email_body_file
set heading off
set feedback off
set verify off
set echo off
set linesize 130
set pagesize 0
connect / as sysdba

set serveroutput on

declare
	n_waiting_sid		dba_waiters.waiting_session%type := 571;
	n_holding_sid		dba_waiters.holding_session%type;
	s_lock_id1		dba_waiters.lock_id1%type;
	s_lock_id2		dba_waiters.lock_id2%type;
	n_blocked_object_id	dba_objects.object_id%type;
	s_blocked_owner		dba_objects.owner%type;
	s_blocked_object_name	dba_objects.object_name%type;
	s_username		v\$session.username%type;
	s_program		v\$session.program%type;
	s_module		v\$session.module%type;
	s_osuser		v\$session.osuser%type;
	s_terminal		v\$session.terminal%type;
	s_action		v\$session.action%type;
	s_waiting_event		v\$session.event%type;
	n_seconds_in_wait	v\$session.seconds_in_wait%type;
	s_blocked_process	varchar(20);
	s_blocked_sql_id	varchar2(20);
	s_blocked_sql_text	varchar2(80);
	s_blocked_rowid		varchar2(20);
	s_bind_value		varchar2(100);

	cursor cur_locks is
		with locks as(
			select	w.session_id waiting_session,
				h.session_id holding_session,
				w.lock_type,
				h.mode_held,
				w.mode_requested,
				w.lock_id1,
				w.lock_id2
			from	dba_locks w, dba_locks h
			where	h.blocking_others =  'Blocking'
			and	h.mode_held      !=  'None'
			and	h.mode_held      !=  'Null'
			and	w.mode_requested !=  'None'
			and	w.lock_type       =  h.lock_type
			and	w.lock_id1        =  h.lock_id1
			and	w.lock_id2        =  h.lock_id2 )
		select	lpad(' ',3*(level-1)) || waiting_session waiting_session,
			lock_type, mode_requested, mode_held,
			lock_id1, lock_id2,
			( select osuser from v\$session where sid = waiting_session ) osuser
		from	(
			select	waiting_session, holding_session, lock_type,
				mode_held, mode_requested, lock_id1,
				lock_id2
			from	locks
			union
			select	holding_session, null, 'None', null, null, null, null from locks
			minus
			select	waiting_session, null, 'None', null, null, null, null from locks
			)
		connect by prior waiting_session = holding_session
		start with holding_session is null;

begin
	for r in cur_locks
	loop
		if r.lock_type = 'None' then
			null;
		else
			--
			-- Print out some information about the waiting session.
			--

			select	holding_session, lock_id1, lock_id2
			into	n_holding_sid, s_lock_id1, s_lock_id2
			from	dba_waiters
			where	waiting_session = r.waiting_session
			and	mode_held <> 'None';

			--
			-- Print basic information about this lock.
			--
			dbms_output.put_line( 'Session ID ' || ltrim( r.waiting_session ) || ' is being blocked by session id ' || n_holding_sid );
			dbms_output.put_line( '----------------------------------------------------------------------------------------------------' );

			--
			-- Print out some information about the holding session.
			--
			select	username, program, module,
				osuser,	terminal, action
			into	s_username, s_program, s_module,
				s_osuser, s_terminal, s_action
			from	v\$session
			where	sid = n_holding_sid;

			dbms_output.put_line( '	Holding SID           = ' || n_holding_sid );
			dbms_output.put_line( '	Holding Username      = ' || s_username );
			dbms_output.put_line( '	Holding Program       = ' || s_program );
			dbms_output.put_line( '	Holding Module        = ' || s_module );
			dbms_output.put_line( '	Holding OSUser        = ' || s_osuser );
			dbms_output.put_line( '	Holding Terminal      = ' || s_terminal );
			dbms_output.put_line( '	Holding Action        = ' || s_action );
			dbms_output.put_line( '	' );

			--
			-- Print out some information about the blocked session.
			--
			select	username, program, module,
				osuser,	terminal, action,
				event, seconds_in_wait
			into	s_username, s_program, s_module,
				s_osuser, s_terminal, s_action,
				s_waiting_event, n_seconds_in_wait
			from	v\$session
			where	sid = r.waiting_session;

			dbms_output.put_line( '	Blocked SID           = ' || ltrim( r.waiting_session ) );
			dbms_output.put_line( '	Blocked Username      = ' || s_username );
			dbms_output.put_line( '	Blocked Program       = ' || s_program );
			dbms_output.put_line( '	Blocked Module        = ' || s_module );
			dbms_output.put_line( '	Blocked OSUser        = ' || s_osuser );
			dbms_output.put_line( '	Blocked Terminal      = ' || s_terminal );
			dbms_output.put_line( '	Blocked Action        = ' || s_action );
			dbms_output.put_line( '	Blocked Wait Event    = ' || s_waiting_event );
			dbms_output.put_line( '	Blocked Wait Seconds  = ' || n_seconds_in_wait );
			dbms_output.put_line( '	' );

--			select	distinct b.object_id, do.owner, do.object_name,
--				b.process
--			into	n_blocked_object_id, s_blocked_owner, s_blocked_object_name,
--				s_blocked_process
--			from	v\$locked_object b, dba_objects do
--			where	b.session_id = n_holding_sid
--			and	b.xidsqn = s_lock_id2
--			and	do.object_id = b.object_id;

			for r in(
				select	b.object_id, do.owner, do.object_name,
					b.process
				from	v\$locked_object b, dba_objects do
				where	b.session_id = n_holding_sid
				and	b.xidsqn = s_lock_id2
				and	do.object_id = b.object_id )
			loop
				if n_blocked_object_id is not null and s_blocked_object_name is not null then
					dbms_output.put_line( '	Blocked Object Info   = OBJID: ' || n_blocked_object_id || ' / OBJ: '
						|| s_blocked_owner || '.' || s_blocked_object_name );
				end if;
			end loop;

			-- Get the SQL statement being executed by the waiting session.
			select	a.sql_id, substr( a.sql_text, 1, 80 )
			into	s_blocked_sql_id, s_blocked_sql_text
			from	v\$sqlarea a, v\$session s
			where	a.sql_id = s.sql_id
			and	s.sid = r.waiting_session;	

			dbms_output.put_line( '	Blocked SQL ID        = ' || s_blocked_sql_id );
			dbms_output.put_line( '	Blocked SQL Text      = ' || s_blocked_sql_text );

			-- Now, get the ROWID of the row being blocked.
			select	dbms_rowid.rowid_create( 1, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row# )
			into	s_blocked_rowid
			from	v\$session
			where	sid = r.waiting_session;

			dbms_output.put_line( '	Blocked ROWID         = ' || s_blocked_rowid );

			--
			-- Later we can expand this to get the values of the bind variables
			-- in case the query has binds.
			--
			dbms_output.put_line( '	' );
			dbms_output.put_line( '	The following bind variables were found for this sql statement' );
			dbms_output.put_line( '	These are the values currently being used and may not be the values' );
			dbms_output.put_line( '	that caused the lock.' );
			dbms_output.put_line( '	' );
				dbms_output.put_line( '		Variable Name                     Data Type        Value' );
				dbms_output.put_line( '		--------------------------------  ---------------  ---------------------------------' );
			for r2 in(
				select	distinct sbc.name, sbc.datatype_string, sbc.value_string,
					sbc.position, sbc.was_captured
				from	v\$sql_bind_capture sbc
				where	sbc.sql_id = s_blocked_sql_id
				order by sbc.position )
			loop
				if r2.was_captured = 'NO' then
					s_bind_value := 'Bind value not captured';
				else
					s_bind_value := substr( r2.value_string, 1, 100 );
				end if;
				dbms_output.put_line( '		' || rpad( r2.name, 34 ) || rpad( r2.datatype_string, 17 ) || s_bind_value );
			end loop;

			dbms_output.put_line( '	' );
			dbms_output.put_line( '	To find the row with the blocking lock use the following query.' );
			dbms_output.put_line( '	--------------------------------------------------------------------------------' );
			dbms_output.put_line( '	SELECT * FROM ' || s_blocked_owner || '.' || s_blocked_object_name
				|| ' WHERE ROWID = ''' || s_blocked_rowid || '''' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( '	' );

		end if;
	end loop;
end;
/

exit;
EOF

if [ -s $email_body_file ]
then
	message_log_sms_text="BLOCKING LOCKS EXIST IN "$ORACLE_SID

	#
	# We have found a line in the messages log that is cause for concern so send some messages.
	# Send an SMS message and an email
	#
	email_subj="WARNING: Blocking locks exist in "$ORACLE_SID

	echo "" >> $email_body_file
	echo "############################################################" >> $email_body_file
	echo "" >> $email_body_file
	echo 'This report created by : '$0 >> $email_body_file
	echo "" >> $email_body_file
	echo "############################################################" >> $email_body_file


	# echo
	# echo This is the text that will be sent via SMS
	# echo
	# echo "########################################################################################################################"
	# echo
	# echo $message_log_sms_text
	# echo
	# echo "########################################################################################################################"
	# echo

	# echo
	# echo This is the text that will be sent via email
	# echo
	# echo "########################################################################################################################"
	# echo
	# cat $email_body_file
	# echo
	# echo "########################################################################################################################"
	# echo

	# mail -s "$email_subj" EMAILDBA -a $email_body_file < $email_body_file
	# echo "$email_body_file" | mailx -s "$email_subj" -a $email_body_file $EMAILDBA
	mail -s "$email_subj" $EMAILDBA < $email_body_file
fi
