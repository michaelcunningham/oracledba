#
# This is a simple test file to test the various functions in the dba.lib library.
#
. /dba/admin/dba.lib

echo
echo Testing the get_filer function.
echo
answer=`get_filer tdcprd`
retval=$?
if [ "$retval" -eq "0" ]
then
  echo "All good."
  echo $answer
elif [ "$retval" -eq "1" ]
then
  echo "no 1 good."
  echo $answer
else
  echo "no 2 good."
  echo $answer
fi

echo "Exit code = "$retval

echo
echo Testing the get_snapshot_date function.
echo
answer=`get_snapshot_date npnetapp108 tdcprd post_cycle.1`
retval=$?
if [ "$retval" -eq "0" ]
then
  echo "All good."
elif [ "$retval" -eq "1" ]
then
  echo "no 1 good."
else
  echo "no 2 good."
fi

echo "Exit code = "$retval

echo
echo Testing the is_listener_running function.
echo
answer=`is_listener_running l_iris`
retval=$?
if [ "$retval" -eq "0" ]
then
  echo "All good."
  echo $answer
elif [ "$retval" -eq "1" ]
then
  echo "no 1 good."
  echo $answer
else
  echo "no 2 good."
  echo $answer
fi

echo "Exit code = "$retval

echo
echo Testing the start_listener function.
echo
answer=`start_listener l_iris`
retval=$?
if [ "$retval" -eq "0" ]
then
  echo $answer
elif [ "$retval" -eq "1" ]
then
  echo $answer
else
  echo $answer
fi

echo "Exit code = "$retval

echo
echo Testing the get_tns_from_orasid function.
echo
answer=`get_tns_from_orasid fcon`
retval=$?
if [ "$retval" -eq "0" ]
then
  echo $answer
elif [ "$retval" -eq "1" ]
then
  echo $answer
else
  echo $answer
fi

echo "Exit code = "$retval
