SID_LIST=$(for i in {16..31}; do printf 'TDB%02d ' $i; done); echo $SID_LIST;
basedir=/mnt/dba/adhoc 

unset SQLPATH
#set -x
for ORACLE_SID in $SID_LIST; do
  export ORACLE_SID;
  echo " === $1: $ORACLE_SID === $(date)";
  nohup $basedir/$1 $ORACLE_SID >> nohup_$ORACLE_SID.txt 2>&1 &
done

echo "Tail instructions for nohup";
for ORACLE_SID in $SID_LIST; do
  echo "tail -F nohup_$ORACLE_SID.txt &";
done
echo "kill %1 %2 %3 %4 %5 %6 %7 %8 %9 %10 %11 %12 %13 %14 %15 %16";
echo "monitor using: watch 'ps -elfjH|grep -A 1 /home/oracle/dba/upgrade'";

echo "Waiting for children..."
time wait
echo "Children are done: $(date)"

