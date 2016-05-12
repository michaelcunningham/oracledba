alter diskgroup COMMON5
	add disk '/dev/raw/raw200', '/dev/raw/raw201'
	drop disk COMMON5_0002, COMMON5_0003
	rebalance power 4;

alter diskgroup DATAPDB05
	add disk '/dev/raw/raw202', '/dev/raw/raw203'
	drop disk DATAPDB05_0002, DATAPDB05_0003
	rebalance power 4;

alter diskgroup DGP08
	add disk '/dev/raw/raw204', '/dev/raw/raw205', '/dev/raw/raw206', '/dev/raw/raw207', '/dev/raw/raw208', '/dev/raw/raw209'
	drop disk DGP08_0000, DGP08_0005, DGP08_0006, DGP08_0007, DGP08_0008, DGP08_0009
	rebalance power 4;

alter diskgroup DGP09
	add disk '/dev/raw/raw210', '/dev/raw/raw211', '/dev/raw/raw212', '/dev/raw/raw213', '/dev/raw/raw214', '/dev/raw/raw215'
	drop disk DGP09_0000, DGP09_0005, DGP09_0006, DGP09_0007, DGP09_0008, DGP09_0009
	rebalance power 4;

alter diskgroup DGP10
	add disk '/dev/raw/raw216', '/dev/raw/raw217', '/dev/raw/raw218', '/dev/raw/raw219', '/dev/raw/raw220', '/dev/raw/raw221'
	drop disk DGP10_0000, DGP10_0005, DGP10_0006, DGP10_0007, DGP10_0008, DGP10_0009
	rebalance power 4;

alter diskgroup DGP11
	add disk '/dev/raw/raw222', '/dev/raw/raw223', '/dev/raw/raw224', '/dev/raw/raw225', '/dev/raw/raw226', '/dev/raw/raw227'
	drop disk DGP11_0000, DGP11_0005, DGP11_0006, DGP11_0007, DGP11_0008, DGP11_0009
	rebalance power 4;

alter diskgroup DGP12
	add disk '/dev/raw/raw228', '/dev/raw/raw229', '/dev/raw/raw230', '/dev/raw/raw231', '/dev/raw/raw232', '/dev/raw/raw233'
	drop disk DGP12_0000, DGP12_0005, DGP12_0006, DGP12_0007, DGP12_0008, DGP12_0009
	rebalance power 4;

alter diskgroup DGP13
	add disk '/dev/raw/raw234', '/dev/raw/raw235', '/dev/raw/raw236', '/dev/raw/raw237', '/dev/raw/raw238', '/dev/raw/raw239'
	drop disk DGP13_0000, DGP13_0005, DGP13_0006, DGP13_0007, DGP13_0008, DGP13_0009
	rebalance power 4;

alter diskgroup DGP14
	add disk '/dev/raw/raw240', '/dev/raw/raw241', '/dev/raw/raw242', '/dev/raw/raw243', '/dev/raw/raw244', '/dev/raw/raw245'
	drop disk DGP14_0000, DGP14_0005, DGP14_0006, DGP14_0007, DGP14_0008, DGP14_0009
	rebalance power 4;

alter diskgroup DGP15
	add disk '/dev/raw/raw246', '/dev/raw/raw247', '/dev/raw/raw248', '/dev/raw/raw249', '/dev/raw/raw250', '/dev/raw/raw251'
	drop disk DGP15_0000, DGP15_0005, DGP15_0006, DGP15_0007, DGP15_0008, DGP15_0009
	rebalance power 4;

