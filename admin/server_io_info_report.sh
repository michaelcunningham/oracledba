#!/bin/sh


log_date=`date +%a`
log_file=/dba/admin/log/server_io_info_$log_date.log

export ORACLE_SID=`ps -ef | grep pmon | grep -v "grep pmon" | cut -f3 -d_ | head -1`
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=dmmaster
userpwd=dm7master

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

alter session set nls_date_format='DD-MON-YYYY';

set linesize 115
set pagesize 100
set feedback off
set verify off
set echo off
set tab off

column server_name       format a8                   heading 'Server'
column instance_name     format a16                  heading 'Instance'
column interface_name    format a6                   heading 'NIC'
column collection_date   format date                 heading 'Date'
column rx_daily          format 999,999,999,999,999  heading 'RX Bytes Daily'
column tx_daily          format 999,999,999,999,999  heading 'TX Bytes Daily'
column rx_packets_daily  format 999,999,999,999,999  heading 'RX Pkt Daily'
column tx_packets_daily  format 999,999,999,999,999  heading 'TX Pkt Daily'
column cpu_seconds_daily format 999,999,999          heading 'CPU Seconds'
column rd_mb_daily       format 999,999,999          heading 'Read MB Daily'
column wrt_mb_daily      format 999,999,999          heading 'Write MB Daily'

column rx_bytes_prior    noprint
column rx_bytes          noprint
column tx_bytes_prior    noprint
column tx_bytes          noprint
column rx_packets_prior  noprint
column rx_packets        noprint
column tx_packets_prior  noprint
column tx_packets        noprint
column cpu_seconds       noprint
column cpu_seconds_prior noprint
column rd_mb             noprint
column rd_mb_prior       noprint
column wrt_mb            noprint
column wrt_mb_prior      noprint

spool $log_file

set linesize 42

ttitle on
ttitle center '***  Daily CPU Usage Per Database  ***' skip 2

select	instance_name, collection_date,
	cpu_seconds, cpu_seconds_prior, cpu_seconds - cpu_seconds_prior cpu_seconds_daily
from	(
	select	instance_name, collection_date,
		cpu_seconds, lag( cpu_seconds, 1, cpu_seconds )
	        		over( partition by instance_name order by collection_date ) as cpu_seconds_prior
	from	(
	        select	instance_name, collection_date, cpu_seconds
	        from	db_cpu_info
	        order by instance_name, collection_date
		)
	)
where	collection_date = trunc( sysdate )
order by instance_name, collection_date;

set linesize 115

prompt
prompt
ttitle on
ttitle center '**********  Daily Network I/O Statistics per server/per nic  **********' skip 2

select	server_name, interface_name, collection_date,
	rx_bytes - rx_bytes_prior rx_daily,
	tx_bytes - tx_bytes_prior tx_daily,
	rx_packets - rx_packets_prior rx_packets_daily,
	tx_packets - tx_packets_prior tx_packets_daily,
	rx_bytes_prior, rx_bytes,
	tx_bytes_prior, tx_bytes,
	rx_packets_prior, rx_packets,
	tx_packets_prior, tx_packets
from	(
	select	server_name, interface_name, collection_date,
		rx_bytes, lag( rx_bytes, 1, rx_bytes )
	        		over( partition by server_name, interface_name order by collection_date ) as rx_bytes_prior,
		tx_bytes, lag( tx_bytes, 1, tx_bytes )
	        		over( partition by server_name, interface_name order by collection_date ) as tx_bytes_prior,
		rx_packets, lag( rx_packets, 1, rx_packets )
	        		over( partition by server_name, interface_name order by collection_date ) as rx_packets_prior,
		tx_packets, lag( tx_packets, 1, tx_packets )
	        		over( partition by server_name, interface_name order by collection_date ) as tx_packets_prior
	from	(
	        select	server_name, interface_name, collection_date,
			rx_packets, tx_packets, rx_bytes, tx_bytes
	        from	server_io_info
	        order by server_name, interface_name, collection_date
		)
	)
where	rx_bytes <> rx_bytes_prior
and	collection_date = trunc( sysdate )
order by server_name, interface_name, collection_date;

set linesize 70

prompt
prompt
ttitle on
ttitle center '**********  Daily Database I/O Statistics  **********' skip 1 -
       center '(does not include locally installed ssd)' skip 2

select	server_name, instance_name, collection_date,
	rd_mb, rd_mb_prior, rd_mb - rd_mb_prior rd_mb_daily,
	wrt_mb, wrt_mb_prior, wrt_mb - wrt_mb_prior wrt_mb_daily
from	(
	select	server_name, instance_name, collection_date,
		rd_mb, lag( rd_mb, 1, rd_mb )
				over( partition by server_name, instance_name order by collection_date ) as rd_mb_prior,
		wrt_mb, lag( wrt_mb, 1, wrt_mb )
				over( partition by server_name, instance_name order by collection_date ) as wrt_mb_prior
	from	(
		select	server_name, instance_name, collection_date,
			sum( lg_rd_mb + sm_rd_mb ) rd_mb,
			sum( lg_wrt_mb + sm_wrt_mb ) wrt_mb
		from	db_io_info
		where	file_name not like '/ssd%'
		group by server_name, instance_name, collection_date
		order by server_name, instance_name, collection_date
		)
	)
where	collection_date = trunc( sysdate )
and	rd_mb <> rd_mb_prior
order by server_name, instance_name, collection_date;

exit;
EOF

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

mail_subject="Server I/O Information"
mail -s "$mail_subject" mcunningham@thedoctors.com < $log_file
# mail -s "$mail_subject" swahby@thedoctors.com < $log_file
# mail -s "$mail_subject" jmitchell@thedoctors.com < $log_file


