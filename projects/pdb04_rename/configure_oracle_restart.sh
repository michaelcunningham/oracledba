#!/bin/sh

export ORACLE_SID=PDB04

export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

srvctl remove database -db pdb04s

srvctl add database -db ${ORACLE_SID}A -dbname ${ORACLE_SID} -instance ${ORACLE_SID} \
-startoption OPEN -role PRIMARY -policy AUTOMATIC \
-spfile $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora \
-pwfile $ORACLE_HOME/dbs/orapw${ORACLE_SID} -oraclehome $ORACLE_HOME \
-diskgroup "COMMON4,DATAPDB04,DGP48,DGP49,DGP50,DGP51,DGP52,DGP53,DGP54,DGP55,LOGPDB04"
