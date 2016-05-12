#!/bin/sh

if [ "$1" = "" ]
then
  storage_type=data 
else
  storage_type=$1
fi

if [ "$storage_type" != "data" -a "$storage_type" != "log" -a "$storage_type" != "backup" ]
then
  echo
  echo "   Usage: $0 <data | log | backup>"
  echo
  echo "   Example: $0 data"
  echo
  echo "   Default parameter = data"
  echo
  exit
fi

#
# There is more than one naming standard for disk groups,
# one has the word 'data', the other just has the letter 'd'.
# Let's look for the 'data' first.  If we don't find it then we will look for 'd'.
# There is also a chance neither of these exist. If not we will try just looking
# for the 'h', 't', or 'v'.
#

if [ ! -f /usr/sbin/vxdg ]
then
  echo "Unknown"
  exit 1
fi

if [ "$storage_type" = "data" ]
then
  vxdg_item=`sudo /usr/sbin/vxdg list | grep enabled | awk '{print $1}' | grep ".*data.*[htv][0-9]\{1,2\}$"`
  # echo "vxdg_item_1   = "$vxdg_item
  if [ -z "$vxdg_item" ]
  then
    vxdg_item=`sudo /usr/sbin/vxdg list | grep enabled | awk '{print $1}' | grep ".*d[htv][0-9]\{1,2\}$"`
    # echo "vxdg_item_2   = "$vxdg_item
    if [ -z "$vxdg_item" ]
    then
      vxdg_item=`sudo /usr/sbin/vxdg list | grep enabled | awk '{print $1}' | grep ".*[htv][0-9]\{1,2\}$"`
      # echo "vxdg_item_3   = "$vxdg_item
      if [ -z "$vxdg_item" ]
      then
        echo "Unknown"
        # echo $vxdg_item
        exit 1
      fi
    fi
  fi
  #
  # If we mad it this far we have found a 'data' disk group.
  #

  unset server_name

  # echo "vxdg_item           "$vxdg_item

  #
  # We have to loop because some servers (ora39) have more that one data mount
  #

  for this_item in $vxdg_item
  do
    vxdg_text=`echo $this_item | sed "s/[0-9]\{1,2\}$//g"`
    vxdg_num=`echo $this_item | sed "s/$vxdg_text//g"`
    num_length=`echo $vxdg_num | awk '{print length($0)}'`
    vxdg_type=`echo $vxdg_text | awk '{print substr($0,length)}'`

    # echo "this_item           "$this_item
    # echo "vxdg_text           "$vxdg_text
    # echo "vxdg_num            "$vxdg_num
    # echo "num_length          "$num_length
    # echo "vxdg_type           "$vxdg_type

    if [ ! -z "$server_name" ]
    then
      server_name=$server_name", "
    fi

    if [ "$vxdg_type" = "h" ]
    then
      server_name=$server_name"Hitachi"$vxdg_num
    elif [ "$vxdg_type" = "t" ]
    then
      server_name=$server_name"3par"$vxdg_num
    elif [ "$vxdg_type" = "v" ]
    then
      server_name=$server_name"Violin"$vxdg_num
    fi
  done

  echo $server_name
  exit
fi


#
# If we made it this far then we are looking for a 'log' type mount
# The code after here has not been completed or tested.
#

if [ "$storage_type" = "log" ]
then
  vxdg_item=`sudo /usr/sbin/vxdg list | grep enabled | awk '{print $1}' | grep ".*log[htv][0-9]\{1,2\}$"`
  if [ -z $vxdg_item ]
  then
    vxdg_item=`sudo /usr/sbin/vxdg list | grep enabled | awk '{print $1}' | grep ".*l[htv][0-9]\{1,2\}$"`
    if [ -z $vxdg_item ]
    then
      echo "Unknown"
      exit 1
    fi
  fi
  #
  # If we mad it this far we have found a 'log' disk group.
  #
  vxdg_text=`echo $vxdg_item | sed "s/[0-9]\{1,2\}$//g"`
  vxdg_num=`echo $vxdg_item | sed "s/$vxdg_text//g"`
  num_length=`echo $vxdg_num | awk '{print length($0)}'`
  vxdg_type=`echo $vxdg_text | awk '{print substr($0,length)}'`
fi

# echo "vxdg_item           "$vxdg_item
# echo "vxdg_text           "$vxdg_text
# echo "vxdg_num            "$vxdg_num
# echo "num_length          "$num_length
# echo "vxdg_type           "$vxdg_type

# If we made it this far then chances are good we have figured out what storage we are using
# That is because we have found on of these [htv]
# Now let's give it a more descriptive name
