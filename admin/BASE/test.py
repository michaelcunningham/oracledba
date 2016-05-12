#!/usr/bin/env python
import sys,string
inputfilename = sys.argv[1]
fname=inputfilename
db = "meetme"
files = ["begin"]
n = 1
while n < 10:
#    file_name = "outfile" + str(n) + ".txt"
    file_name=fname.replace("pxx",str(db)+str(n))
    file_name=file_name.replace("xx",str(db)+str(n))
    files.append(file_name)
    n = n + 1
n = 1
while n < 9:
    file_name = files[n]
    x = open(file_name, 'w')
    n = n + 1
n = 1
while n < 9:
    file_name = files[n]
    if n is 1:
    	file_name.write(" 1write it \n")
    else:
	if n is 5:
		file_name.write(" 5 write it \n")
	else:
		file_name.write(" all write it \n")
    n = n + 1
n = 1
while n < 9:
    file_name = files[n]
    x.close()
    n = n + 1

