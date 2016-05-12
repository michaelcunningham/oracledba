#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <message> <process> <trace>"
  echo
  echo "   Example: $0 \"CLONE FAILED\" \"Clone Database\" \"tdcprd to tdcsnp\""
  echo
  echo "   Optional: $0 <message> <process_name> <trace_text> <trace_brief> <trace_detail>"
  echo
  exit
fi

message_text=$1  # This should be a brief (15 chars) piece of data such as the ORACLE_SID
process_name=$2   # This should be what was happening such as a database backup or clone
trace_text=$3   # This could be the database being backed up, or clone source and target (ORACLE_SID)

. /dba/admin/dba.lib

#
# We need an ORACLE_SID to use so we can set the environment.  Let's find one.
# Since this script can be run from any Linux server we need to do this dynamically
# because we don't know which instance to use up front.
#
#export ORACLE_SID=`ps -ef | grep ora_pmon | grep -v "grep ora_pmon"| awk '{print $8}' | awk -F_ '{print $3}' | head -1`
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=tdc247
username=tdcglobal
userpwd=`get_user_pwd $tns $username`

echo "Running SqlPlus in applog_message..."

sqlplus -s $username/$userpwd@$tns << EOF
declare
	n_return number;
	function html_encode( p_value in varchar2 ) return varchar2 is
	begin
		return replace( replace( replace( replace( replace( p_value, '&', chr(38) || 'amp;'),
			'<', chr(38) || 'lt;'), '>', chr(38) || 'gt;'), '@', chr(38) || '#64;'), '\', chr(38) || '#92;' );
	end html_encode;
	--
	function get_applog_url return varchar2
	is
		v_app_log_url varchar2(255);
	begin
		select	lu_sys_schema_env_param.environment_parameter_value
		into	v_app_log_url
		from	lu_sys_schema_env_param
		where	lu_sys_schema_env_param.sys_schema_env_param_type_code = 'APPLOG_URL';
		return v_app_log_url;
	end get_applog_url;
	--
	function get_db_name return varchar2
	is
		n_intval binary_integer;
		n_instance varchar2(256);
	begin
		n_intval := dbms_utility.get_parameter_value( 'instance_name', n_intval, n_instance );
		return n_instance;
	end get_db_name;
	--
	function applog_message(
		p_source_system in varchar2,
		p_log_number in number,
		p_process_name in varchar2,
		p_message in varchar2,
		p_trace_info in varchar2 ) return number
	is
		v_applog_url varchar2(255) := get_applog_url();
		v_soap_request varchar2(30000);
		v_soap_respond varchar2(30000);
		v_log_envelope varchar2(30000);
		v_http_req utl_http.req;
		v_http_resp utl_http.resp;
		v_soap_resp xmltype;
		v_ret_val number(1) := 1;
	begin
		-- Create XML/SOAP header information
		v_soap_request := '<?xml version="1.0" encoding="utf-8"?>'
			|| '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
			|| 'xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
			|| '<soap:Body><LogMessage xmlns="http://tempuri.org/">';
		-- Create SOAP envelope
		 v_log_envelope := '<logEnv>';
		 v_log_envelope := v_log_envelope || '<SourceSystem>'      || html_encode( p_source_system )    || '</SourceSystem>';
		 v_log_envelope := v_log_envelope || '<LogNumber>'         || p_log_number                      || '</LogNumber>';
		 v_log_envelope := v_log_envelope || '<Message>'           || html_encode( p_message )          || '</Message>';
		 v_log_envelope := v_log_envelope || '<ProcessName>'       || html_encode( p_process_name )     || '</ProcessName>';
		 v_log_envelope := v_log_envelope || '<TraceInfo>'         || html_encode( p_trace_info )       || '</TraceInfo>';
		 v_log_envelope := v_log_envelope || '<EnvironenmentInfo>' || html_encode( upper( get_db_name() ) ) || '</EnvironenmentInfo>';
		 v_log_envelope := v_log_envelope || '</logEnv>';
		 v_soap_request := v_soap_request || v_log_envelope || '</LogMessage></soap:Body> </soap:Envelope>';
		-- Prepare SOAP call
		v_http_req := utl_http.begin_request( v_applog_url, 'POST', 'HTTP/1.1' );
		utl_http.set_header( v_http_req, 'Content-Type', 'text/xml' );
		utl_http.set_header( v_http_req, 'Content-Length', LENGTH(v_soap_request ) );
		utl_http.set_header( v_http_req, 'SOAPAction', 'http://tempuri.org/LogMessage' ); -- required to specify this is a SOAP communication
		utl_http.write_text( v_http_req, v_soap_request );
		-- Make the SOAP Call
		v_http_resp := utl_http.get_response( v_http_req );
		-- Read the returning XML
		utl_http.read_text( v_http_resp, v_soap_respond );
		utl_http.end_response( v_http_resp );
	 	return ( v_ret_val );
	exception
	 	when others then
	  		return ( 0 ); -- error condition
	end applog_message;
begin
	n_return := applog_message( 'DBA', 0, '$process_name', '$message_text', '$trace_text' );
end;
/
exit;
EOF

