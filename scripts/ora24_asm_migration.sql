alter diskgroup COMMON7
	add disk '/dev/raw/raw100', '/dev/raw/raw101'
	drop disk COMMON7_0002, COMMON7_0003
	rebalance power 4;

alter diskgroup DATAPDB07
	add disk '/dev/raw/raw102', '/dev/raw/raw151'
	drop disk DATAPDB07_0001
	rebalance power 4;

alter diskgroup DGP40
	add disk '/dev/raw/raw103', '/dev/raw/raw104', '/dev/raw/raw105', '/dev/raw/raw106', '/dev/raw/raw107', '/dev/raw/raw108'
	drop disk DGP40_0000, DGP40_0005, DGP40_0006, DGP40_0007, DGP40_0008, DGP40_0009
	rebalance power 4;

alter diskgroup DGP41
	add disk '/dev/raw/raw109', '/dev/raw/raw110', '/dev/raw/raw111', '/dev/raw/raw112', '/dev/raw/raw113', '/dev/raw/raw114'
	drop disk DGP41_0000, DGP41_0005, DGP41_0006, DGP41_0007, DGP41_0008, DGP41_0009
	rebalance power 4;

alter diskgroup DGP42
	add disk '/dev/raw/raw115', '/dev/raw/raw116', '/dev/raw/raw117', '/dev/raw/raw118', '/dev/raw/raw119', '/dev/raw/raw120'
	drop disk DGP42_0000, DGP42_0005, DGP42_0006, DGP42_0007, DGP42_0008, DGP42_0009
	rebalance power 4;

alter diskgroup DGP43
	add disk '/dev/raw/raw121', '/dev/raw/raw122', '/dev/raw/raw123', '/dev/raw/raw124', '/dev/raw/raw125', '/dev/raw/raw126'
	drop disk DGP43_0000, DGP43_0005, DGP43_0006, DGP43_0007, DGP43_0008, DGP43_0009
	rebalance power 4;

alter diskgroup DGP44
	add disk '/dev/raw/raw127', '/dev/raw/raw128', '/dev/raw/raw129', '/dev/raw/raw130', '/dev/raw/raw131', '/dev/raw/raw132'
	drop disk DGP44_0000, DGP44_0005, DGP44_0006, DGP44_0007, DGP44_0008, DGP44_0009
	rebalance power 4;

alter diskgroup DGP45
	add disk '/dev/raw/raw133', '/dev/raw/raw134', '/dev/raw/raw135', '/dev/raw/raw136', '/dev/raw/raw137', '/dev/raw/raw138'
	drop disk DGP45_0000, DGP45_0005, DGP45_0006, DGP45_0007, DGP45_0008, DGP45_0009
	rebalance power 4;

alter diskgroup DGP46
	add disk '/dev/raw/raw139', '/dev/raw/raw140', '/dev/raw/raw141', '/dev/raw/raw142', '/dev/raw/raw143', '/dev/raw/raw144'
	drop disk DGP46_0000, DGP46_0005, DGP46_0006, DGP46_0007, DGP46_0008, DGP46_0009
	rebalance power 4;

alter diskgroup DGP47
	add disk '/dev/raw/raw145', '/dev/raw/raw146', '/dev/raw/raw147', '/dev/raw/raw148', '/dev/raw/raw149', '/dev/raw/raw150'
	drop disk DGP47_0000, DGP47_0005, DGP47_0006, DGP47_0007, DGP47_0008, DGP47_0009
	rebalance power 4;

