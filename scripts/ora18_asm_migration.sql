alter diskgroup COMMON2
	add disk '/dev/raw/raw100', '/dev/raw/raw101'
	drop disk COMMON2_0002, COMMON2_0003
	rebalance power 20;

alter diskgroup DATAPDB02
	add disk '/dev/raw/raw102'
	drop disk DATAPDB02_0001
	rebalance power 20;

alter diskgroup DGP16
	add disk '/dev/raw/raw103', '/dev/raw/raw104', '/dev/raw/raw105', '/dev/raw/raw106', '/dev/raw/raw107', '/dev/raw/raw108'
	drop disk DGP16_0000, DGP16_0005, DGP16_0006, DGP16_0007, DGP16_0008, DGP16_0009
	rebalance power 20;

alter diskgroup DGP17
	add disk '/dev/raw/raw109', '/dev/raw/raw110', '/dev/raw/raw111', '/dev/raw/raw112', '/dev/raw/raw113', '/dev/raw/raw114'
	drop disk DGP17_0000, DGP17_0005, DGP17_0006, DGP17_0007, DGP17_0008, DGP17_0009
	rebalance power 20;

alter diskgroup DGP18
	add disk '/dev/raw/raw115', '/dev/raw/raw116', '/dev/raw/raw117', '/dev/raw/raw118', '/dev/raw/raw119', '/dev/raw/raw120'
	drop disk DGP18_0000, DGP18_0005, DGP18_0006, DGP18_0007, DGP18_0008, DGP18_0009
	rebalance power 20;

alter diskgroup DGP19
	add disk '/dev/raw/raw121', '/dev/raw/raw122', '/dev/raw/raw123', '/dev/raw/raw124', '/dev/raw/raw125', '/dev/raw/raw126'
	drop disk DGP19_0000, DGP19_0005, DGP19_0006, DGP19_0007, DGP19_0008, DGP19_0009
	rebalance power 20;

alter diskgroup DGP20
	add disk '/dev/raw/raw127', '/dev/raw/raw128', '/dev/raw/raw129', '/dev/raw/raw130', '/dev/raw/raw131', '/dev/raw/raw132'
	drop disk DGP20_0000, DGP20_0005, DGP20_0006, DGP20_0007, DGP20_0008, DGP20_0009
	rebalance power 20;

alter diskgroup DGP21
	add disk '/dev/raw/raw133', '/dev/raw/raw134', '/dev/raw/raw135', '/dev/raw/raw136', '/dev/raw/raw137', '/dev/raw/raw138'
	drop disk DGP21_0000, DGP21_0005, DGP21_0006, DGP21_0007, DGP21_0008, DGP21_0009
	rebalance power 20;

alter diskgroup DGP22
	add disk '/dev/raw/raw139', '/dev/raw/raw140', '/dev/raw/raw141', '/dev/raw/raw142', '/dev/raw/raw143', '/dev/raw/raw144'
	drop disk DGP22_0000, DGP22_0005, DGP22_0006, DGP22_0007, DGP22_0008, DGP22_0009
	rebalance power 20;

alter diskgroup DGP23
	add disk '/dev/raw/raw145', '/dev/raw/raw146', '/dev/raw/raw147', '/dev/raw/raw148', '/dev/raw/raw149', '/dev/raw/raw150'
	drop disk DGP23_0000, DGP23_0005, DGP23_0006, DGP23_0007, DGP23_0008, DGP23_0009
	rebalance power 20;

