alter diskgroup COMMON3
	add disk '/dev/raw/raw100', '/dev/raw/raw101'
	drop disk COMMON3_0000, COMMON3_0001
	rebalance power 4;

alter diskgroup LOGPDB03
	add disk '/dev/raw/raw151'
	drop disk LOGPDB03_0000
	rebalance power 4;

alter diskgroup DATAPDB03
	add disk '/dev/raw/raw102'
	drop disk DATAPDB03_0001
	rebalance power 4;

alter diskgroup DGP32
	add disk '/dev/raw/raw103', '/dev/raw/raw104', '/dev/raw/raw105', '/dev/raw/raw106', '/dev/raw/raw107', '/dev/raw/raw108'
	drop disk DGP32_0001, DGP32_0002, DGP32_0003, DGP32_0004, DGP32_0010, DGP32_0011
	rebalance power 4;

alter diskgroup DGP33
	add disk '/dev/raw/raw109', '/dev/raw/raw110', '/dev/raw/raw111', '/dev/raw/raw112', '/dev/raw/raw113', '/dev/raw/raw114'
	drop disk DGP33_0001, DGP33_0002, DGP33_0003, DGP33_0004, DGP33_0010, DGP33_0011
	rebalance power 4;

alter diskgroup DGP34
	add disk '/dev/raw/raw115', '/dev/raw/raw116', '/dev/raw/raw117', '/dev/raw/raw118', '/dev/raw/raw119', '/dev/raw/raw120'
	drop disk DGP34_0001, DGP34_0002, DGP34_0003, DGP34_0004, DGP34_0010, DGP34_0011
	rebalance power 4;

alter diskgroup DGP35
	add disk '/dev/raw/raw121', '/dev/raw/raw122', '/dev/raw/raw123', '/dev/raw/raw124', '/dev/raw/raw125', '/dev/raw/raw126'
	drop disk DGP35_0001, DGP35_0002, DGP35_0003, DGP35_0004, DGP35_0010, DGP35_0011
	rebalance power 4;

alter diskgroup DGP36
	add disk '/dev/raw/raw127', '/dev/raw/raw128', '/dev/raw/raw129', '/dev/raw/raw130', '/dev/raw/raw131', '/dev/raw/raw132'
	drop disk DGP36_0001, DGP36_0002, DGP36_0003, DGP36_0004, DGP36_0010, DGP36_0011
	rebalance power 4;

alter diskgroup DGP37
	add disk '/dev/raw/raw133', '/dev/raw/raw134', '/dev/raw/raw135', '/dev/raw/raw136', '/dev/raw/raw137', '/dev/raw/raw138'
	drop disk DGP37_0001, DGP37_0002, DGP37_0003, DGP37_0004, DGP37_0010, DGP37_0011
	rebalance power 4;

alter diskgroup DGP38
	add disk '/dev/raw/raw139', '/dev/raw/raw140', '/dev/raw/raw141', '/dev/raw/raw142', '/dev/raw/raw143', '/dev/raw/raw144'
	drop disk DGP38_0001, DGP38_0002, DGP38_0003, DGP38_0004, DGP38_0010, DGP38_0011
	rebalance power 4;

alter diskgroup DGP39
	add disk '/dev/raw/raw145', '/dev/raw/raw146', '/dev/raw/raw147', '/dev/raw/raw148', '/dev/raw/raw149', '/dev/raw/raw150'
	drop disk DGP39_0001, DGP39_0002, DGP39_0003, DGP39_0004, DGP39_0010, DGP39_0011
	rebalance power 4;

