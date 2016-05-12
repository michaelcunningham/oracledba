#!/usr/bin/env python
import sys,string
inputfilename = sys.argv[1]
numfrom = sys.argv[2]
currnum =int(numfrom)
nextnum = currnum
count = 0
while count < 19:
        inputfile = open(inputfilename,"r")
        outputfilename=inputfilename.replace("xx",str(nextnum))
        outputfile=open(outputfilename,"w")
        for line in inputfile.readlines():
                data=line.replace("xx",str(nextnum));
                outputfile.write(data);
        outputfile.close()
        nextnum = nextnum + 8
        count = count + 1
        inputfile.close()
