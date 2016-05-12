alter diskgroup COMMON8
	add disk '/dev/raw/raw100', '/dev/raw/raw101'
	drop disk COMMON8_0000, COMMON8_0001
	rebalance power 4;

alter diskgroup DATAPDB08
	add disk '/dev/raw/raw102'
	drop disk DATAPDB08_0000
	rebalance power 4;

alter diskgroup DGP56
	add disk '/dev/raw/raw103', '/dev/raw/raw104', '/dev/raw/raw105', '/dev/raw/raw106', '/dev/raw/raw107', '/dev/raw/raw108'
	drop disk DGP56_0001, DGP56_0002, DGP56_0003, DGP56_0004, DGP56_0010, DGP56_0011
	rebalance power 4;

alter diskgroup DGP57
	add disk '/dev/raw/raw109', '/dev/raw/raw110', '/dev/raw/raw111', '/dev/raw/raw112', '/dev/raw/raw113', '/dev/raw/raw114'
	drop disk DGP57_0001, DGP57_0002, DGP57_0003, DGP57_0004, DGP57_0010, DGP57_0011
	rebalance power 4;

alter diskgroup DGP58
	add disk '/dev/raw/raw115', '/dev/raw/raw116', '/dev/raw/raw117', '/dev/raw/raw118', '/dev/raw/raw119', '/dev/raw/raw120'
	drop disk DGP58_0001, DGP58_0002, DGP58_0003, DGP58_0004, DGP58_0010, DGP58_0011
	rebalance power 4;

alter diskgroup DGP59
	add disk '/dev/raw/raw121', '/dev/raw/raw122', '/dev/raw/raw123', '/dev/raw/raw124', '/dev/raw/raw125', '/dev/raw/raw126'
	drop disk DGP59_0001, DGP59_0002, DGP59_0003, DGP59_0004, DGP59_0010, DGP59_0011
	rebalance power 4;

alter diskgroup DGP60
	add disk '/dev/raw/raw127', '/dev/raw/raw128', '/dev/raw/raw129', '/dev/raw/raw130', '/dev/raw/raw131', '/dev/raw/raw132'
	drop disk DGP60_0001, DGP60_0002, DGP60_0003, DGP60_0004, DGP60_0010, DGP60_0011
	rebalance power 4;

alter diskgroup DGP61
	add disk '/dev/raw/raw133', '/dev/raw/raw134', '/dev/raw/raw135', '/dev/raw/raw136', '/dev/raw/raw137', '/dev/raw/raw138'
	drop disk DGP61_0001, DGP61_0002, DGP61_0003, DGP61_0004, DGP61_0010, DGP61_0011
	rebalance power 4;

alter diskgroup DGP62
	add disk '/dev/raw/raw139', '/dev/raw/raw140', '/dev/raw/raw141', '/dev/raw/raw142', '/dev/raw/raw143', '/dev/raw/raw144'
	drop disk DGP62_0001, DGP62_0002, DGP62_0003, DGP62_0004, DGP62_0010, DGP62_0011
	rebalance power 4;

alter diskgroup DGP63
	add disk '/dev/raw/raw145', '/dev/raw/raw146', '/dev/raw/raw147', '/dev/raw/raw148', '/dev/raw/raw149', '/dev/raw/raw150'
	drop disk DGP63_0001, DGP63_0002, DGP63_0003, DGP63_0004, DGP63_0010, DGP63_0011
	rebalance power 4;

