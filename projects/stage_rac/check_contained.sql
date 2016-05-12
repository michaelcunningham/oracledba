EXECUTE DBMS_TTS.TRANSPORT_SET_CHECK('datatbs1','indxtbs1','datatbs2','indxtbs2','dataqueuetbs1','indxqueuetbs1','datapetstbs1','indxpetstbs1', TRUE);

SELECT * FROM TRANSPORT_SET_VIOLATIONS;
