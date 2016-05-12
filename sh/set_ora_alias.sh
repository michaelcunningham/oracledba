#!/bin/sh

result=`echo $ORACLE_HOME | awk '{print match($0,"12.1")}'`
if [ $result -gt 0 ]
then
  if [ "$ORACLE_SID" = "+ASM" ]
  then
    ORACLE_SID_LOWER=`echo $ORACLE_SID | tr '[:upper:]' '[:lower:]'`
    alias alert="cd $ORACLE_BASE/diag/asm/"$ORACLE_SID_LOWER"/$ORACLE_SID/trace;tail -30 alert_$ORACLE_SID.log"
    alias alertt="tail -50f $ORACLE_BASE/diag/asm/"$ORACLE_SID_LOWER"/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    alias bdump="cd $ORACLE_BASE/diag/asm/"$ORACLE_SID_LOWER"/$ORACLE_SID/trace;pwd"
    alias udump="cd $ORACLE_BASE/diag/asm/"$ORACLE_SID_LOWER"/$ORACLE_SID/trace;pwd"
  else
    alias alert='cd $ORACLE_BASE/diag/rdbms/*/$ORACLE_SID/trace;tail -30 alert_$ORACLE_SID.log'
    alias alertt='tail -50f $ORACLE_BASE/diag/rdbms/*/$ORACLE_SID/trace/alert_$ORACLE_SID.log'
    alias bdump='cd $ORACLE_BASE/diag/rdbms/*/$ORACLE_SID/trace;pwd'
    alias udump='cd $ORACLE_BASE/diag/rdbms/*/$ORACLE_SID/trace;pwd'
  fi
  return
fi

result=`echo $ORACLE_HOME | awk '{print match($0,"11.")}'`
if [ $result -gt 0 ]
then
  if [ "$ORACLE_SID" = "+ASM" ]
  then
    ORACLE_SID_LOWER=`echo $ORACLE_SID | tr '[:upper:]' '[:lower:]'`
    alias alert="cd $ORACLE_BASE/diag/asm/"$ORACLE_SID_LOWER"/$ORACLE_SID/trace;tail -30 alert_$ORACLE_SID.log"
    alias alertt="tail -50f $ORACLE_BASE/diag/asm/"$ORACLE_SID_LOWER"/$ORACLE_SID/trace/alert_$ORACLE_SID.log"
    alias bdump="cd $ORACLE_BASE/diag/asm/"$ORACLE_SID_LOWER"/$ORACLE_SID/trace;pwd"
    alias udump="cd $ORACLE_BASE/diag/asm/"$ORACLE_SID_LOWER"/$ORACLE_SID/trace;pwd"
  else
    alias alert='cd $ORACLE_BASE/diag/rdbms/$ORACLE_SID/$ORACLE_SID/trace;tail -30 alert_$ORACLE_SID.log'
    alias alertt='tail -50f $ORACLE_BASE/diag/rdbms/$ORACLE_SID/$ORACLE_SID/trace/alert_$ORACLE_SID.log'
    alias bdump='cd $ORACLE_BASE/diag/rdbms/$ORACLE_SID/$ORACLE_SID/trace;pwd'
    alias udump='cd $ORACLE_BASE/diag/rdbms/$ORACLE_SID/$ORACLE_SID/trace;pwd'
  fi
  return
fi

result=`echo $ORACLE_HOME | awk '{print match($0,"10.2")}'`
if [ $result -gt 0 ]
then
  alias alert='cd $ORACLE_BASE/admin/$ORACLE_SID/bdump;tail -30 alert_$ORACLE_SID.log'
  alias alertt='tail -50f $ORACLE_BASE/admin/$ORACLE_SID/bdump/alert_$ORACLE_SID.log'
  alias bdump='cd $ORACLE_BASE/admin/$ORACLE_SID/bdump;pwd'
  alias udump='cd $ORACLE_BASE/admin/$ORACLE_SID/udump;pwd'
  return
fi

