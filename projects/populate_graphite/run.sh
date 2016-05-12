while read this_line
do
	time=`echo $this_line | awk '{print $1}'`
	value=`echo $this_line | awk '{print $2}'`
	echo "tagged.database.total_size_mb.PDB01" $value $time | /usr/bin/nc -w 3 graphite01 2003
done < PDB01.txt

