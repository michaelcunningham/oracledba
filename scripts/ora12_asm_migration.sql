alter diskgroup COMMON4
	add disk '/dev/raw/raw100', '/dev/raw/raw101'
	drop disk COMMON4_0002, COMMON4_0003
	rebalance power 4;


alter diskgroup DATAPDB04
	add disk '/dev/raw/raw102'
	drop disk DATAPDB04_0000
	rebalance power 4;


alter diskgroup DGP48
	add disk '/dev/raw/raw103', '/dev/raw/raw104', '/dev/raw/raw105', '/dev/raw/raw106', '/dev/raw/raw107', '/dev/raw/raw108'
	drop disk DGP48_0000, DGP48_0005, DGP48_0006, DGP48_0007, DGP48_0008, DGP48_0009
	rebalance power 4;


alter diskgroup DGP49
	add disk '/dev/raw/raw109', '/dev/raw/raw110', '/dev/raw/raw111', '/dev/raw/raw112', '/dev/raw/raw113', '/dev/raw/raw114'
	drop disk DGP49_0000, DGP49_0005, DGP49_0006, DGP49_0007, DGP49_0008, DGP49_0009
	rebalance power 4;


alter diskgroup DGP50
	add disk '/dev/raw/raw115', '/dev/raw/raw116', '/dev/raw/raw117', '/dev/raw/raw118', '/dev/raw/raw119', '/dev/raw/raw120'
	drop disk DGP50_0000, DGP50_0005, DGP50_0006, DGP50_0007, DGP50_0008, DGP50_0009
	rebalance power 4;


alter diskgroup DGP51
	add disk '/dev/raw/raw121', '/dev/raw/raw122', '/dev/raw/raw123', '/dev/raw/raw124', '/dev/raw/raw125', '/dev/raw/raw126'
	drop disk DGP51_0000, DGP51_0005, DGP51_0006, DGP51_0007, DGP51_0008, DGP51_0009
	rebalance power 4;


alter diskgroup DGP52
	add disk '/dev/raw/raw127', '/dev/raw/raw128', '/dev/raw/raw129', '/dev/raw/raw130', '/dev/raw/raw131', '/dev/raw/raw132'
	drop disk DGP52_0000, DGP52_0005, DGP52_0006, DGP52_0007, DGP52_0008, DGP52_0009
	rebalance power 4;


alter diskgroup DGP53
	add disk '/dev/raw/raw133', '/dev/raw/raw134', '/dev/raw/raw135', '/dev/raw/raw136', '/dev/raw/raw137', '/dev/raw/raw138'
	drop disk DGP53_0000, DGP53_0005, DGP53_0006, DGP53_0007, DGP53_0008, DGP53_0009
	rebalance power 4;


alter diskgroup DGP54
	add disk '/dev/raw/raw139', '/dev/raw/raw140', '/dev/raw/raw141', '/dev/raw/raw142', '/dev/raw/raw143', '/dev/raw/raw144'
	drop disk DGP54_0000, DGP54_0005, DGP54_0006, DGP54_0007, DGP54_0008, DGP54_0009
	rebalance power 4;


alter diskgroup DGP55
	add disk '/dev/raw/raw145', '/dev/raw/raw146', '/dev/raw/raw147', '/dev/raw/raw148', '/dev/raw/raw149', '/dev/raw/raw150'
	drop disk DGP55_0000, DGP55_0005, DGP55_0006, DGP55_0007, DGP55_0008, DGP55_0009
	rebalance power 4;


