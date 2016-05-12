#!/bin/sh

server_name=`hostname | cut -d. -f1`

nic_list=`/sbin/ifconfig | egrep -v "^ |lo" | awk /./ | cut -f1 -d" "`

for this_nic in $nic_list
do
  interface_name=$this_nic

  ip_address=`/sbin/ifconfig $this_nic | grep "inet addr" | cut -d: -f2 | cut -d" " -f1`

  rx_packets=`/sbin/ifconfig $this_nic | grep "RX packets" | cut -d: -f2 | cut -d" " -f1`
  tx_packets=`/sbin/ifconfig $this_nic | grep "TX packets" | cut -d: -f2 | cut -d" " -f1`

  rx_bytes=`/sbin/ifconfig $this_nic | grep "RX bytes" | cut -d: -f2 | cut -d" " -f1`
  tx_bytes=`/sbin/ifconfig $this_nic | grep "RX bytes" | cut -d: -f3 | cut -d" " -f1`

  if [ $rx_packets -ne 0 ]
  then
    rx_packet_avg_size=`echo $(($rx_bytes/$rx_packets))`
  fi

  if [ $tx_packets -ne 0 ]
  then
    tx_packet_avg_size=`echo $(($tx_bytes/$tx_packets))`
  fi

  echo
  echo 'server_name                 : '$server_name
  echo 'interface_name              : '$interface_name
  echo 'ip_address                  : '$ip_address
  echo 'rx_packets                  : '$rx_packets
  echo 'tx_packets                  : '$tx_packets
  echo 'rx_bytes                    : '$rx_bytes
  echo 'tx_bytes                    : '$tx_bytes
  echo 'rx_packet_avg_size          : '$rx_packet_avg_size
  echo 'tx_packet_avg_size          : '$tx_packet_avg_size
  echo

if [ "$ip_address" != "" ]
then

export ORACLE_SID=`ps -ef | grep pmon | grep -v "grep pmon" | cut -f3 -d_ | head -1`
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=dmmaster
userpwd=dm7master

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

set feedback off

declare
begin
	merge into server_io_info t
	using (
		select	'$server_name' server_name,
			'$interface_name' interface_name,
			trunc(sysdate) collection_date,
			'$ip_address' ip_address,
			'$rx_packets' rx_packets,
			'$tx_packets' tx_packets,
			'$rx_bytes' rx_bytes,
			'$tx_bytes' tx_bytes
		from	dual ) s
	on	( t.server_name = s.server_name and t.interface_name = s.interface_name and t.collection_date = s.collection_date )
	when matched then
		update
		set	ip_address = s.ip_address,
			rx_packets = s.rx_packets,
			tx_packets = s.tx_packets,
			rx_bytes = s.rx_bytes,
			tx_bytes = s.tx_bytes
	when not matched then insert(
			server_name, interface_name, collection_date,
			ip_address, rx_packets, tx_packets,
			rx_bytes, tx_bytes )
		values(
			'$server_name', '$interface_name', trunc(sysdate),
			'$ip_address', '$rx_packets', '$tx_packets',
			'$rx_bytes', '$tx_bytes' );
	commit;

end;
/

exit;
EOF

fi

done
