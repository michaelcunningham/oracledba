alter diskgroup COMMON3
	add disk '/dev/raw/raw100', '/dev/raw/raw101'
	drop disk COMMON3_0002, COMMON3_0003
	rebalance power 4;

alter diskgroup DATAPDB03
	add disk '/dev/raw/raw102'
	drop disk DATAPDB03_0000
	rebalance power 4;

alter diskgroup DGP32
	add disk '/dev/raw/raw103', '/dev/raw/raw104', '/dev/raw/raw105', '/dev/raw/raw106', '/dev/raw/raw107', '/dev/raw/raw108'
	drop disk DGP32_0000, DGP32_0005, DGP32_0006, DGP32_0007, DGP32_0008, DGP32_0009
	rebalance power 4;

alter diskgroup DGP33
	add disk '/dev/raw/raw109', '/dev/raw/raw110', '/dev/raw/raw111', '/dev/raw/raw112', '/dev/raw/raw113', '/dev/raw/raw114'
	drop disk DGP33_0000, DGP33_0005, DGP33_0006, DGP33_0007, DGP33_0008, DGP33_0009
	rebalance power 4;

alter diskgroup DGP34
	add disk '/dev/raw/raw115', '/dev/raw/raw116', '/dev/raw/raw117', '/dev/raw/raw118', '/dev/raw/raw119', '/dev/raw/raw120'
	drop disk DGP34_0000, DGP34_0005, DGP34_0006, DGP34_0007, DGP34_0008, DGP34_0009
	rebalance power 4;

alter diskgroup DGP35
	add disk '/dev/raw/raw121', '/dev/raw/raw122', '/dev/raw/raw123', '/dev/raw/raw124', '/dev/raw/raw125', '/dev/raw/raw126'
	drop disk DGP35_0000, DGP35_0005, DGP35_0006, DGP35_0007, DGP35_0008, DGP35_0009
	rebalance power 4;

alter diskgroup DGP36
	add disk '/dev/raw/raw127', '/dev/raw/raw128', '/dev/raw/raw129', '/dev/raw/raw130', '/dev/raw/raw131', '/dev/raw/raw132'
	drop disk DGP36_0000, DGP36_0005, DGP36_0006, DGP36_0007, DGP36_0008, DGP36_0009
	rebalance power 4;

alter diskgroup DGP37
	add disk '/dev/raw/raw133', '/dev/raw/raw134', '/dev/raw/raw135', '/dev/raw/raw136', '/dev/raw/raw137', '/dev/raw/raw138'
	drop disk DGP37_0000, DGP37_0005, DGP37_0006, DGP37_0007, DGP37_0008, DGP37_0009
	rebalance power 4;

alter diskgroup DGP38
	add disk '/dev/raw/raw139', '/dev/raw/raw140', '/dev/raw/raw141', '/dev/raw/raw142', '/dev/raw/raw143', '/dev/raw/raw144'
	drop disk DGP38_0000, DGP38_0005, DGP38_0006, DGP38_0007, DGP38_0008, DGP38_0009
	rebalance power 4;

alter diskgroup DGP39
	add disk '/dev/raw/raw145', '/dev/raw/raw146', '/dev/raw/raw147', '/dev/raw/raw148', '/dev/raw/raw149', '/dev/raw/raw150'
	drop disk DGP39_0000, DGP39_0005, DGP39_0006, DGP39_0007, DGP39_0008, DGP39_0009
	rebalance power 4;

