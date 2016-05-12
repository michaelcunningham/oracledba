for f in $(ls -1 /var/log/sa/sa[0-9][0-9]); do sar -u -f $f | egrep -v "Linux|CPU" | sort -n -k4 | tail -1; done 
