create table messages_p0105_0415 tablespace  P20150415_20150724_TBS
as select * from messages partition(P20150105_20150415);
