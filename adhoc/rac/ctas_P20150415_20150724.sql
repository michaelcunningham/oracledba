create table messages_p0415_0724 tablespace P20150415_20150724_TBS
as select * from messages partition(P20150415_20150724);
