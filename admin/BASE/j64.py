#!/usr/bin/env python
import sys,string
inputfilename = sys.argv[1]
env = sys.argv[2]
dbtype = sys.argv[3]
db=env+dbtype
suffix=db
suffix=suffix.replace("DEVpdbs","devpdb")
suffix=suffix.replace("DEVmeetme","devpdb")
suffix=suffix.replace("STAGEpdbs","spdb")
suffix=suffix.replace("spdb","spdb")
suffix=suffix.replace("STAGEmeetme","spdb")
suffix=suffix.replace("PRODpdbs","pdb")
suffix=suffix.replace("PRODmeetme","mmdb")

fname=inputfilename
fname=fname.replace("pxx","xx")
numfrom = 0
currnum =int(numfrom)
nextnum = currnum 
count = 0
while count < 64:
	inputfile = open(inputfilename,"r")
	outputfilename=fname.replace("xx",str(nextnum))
	outputfile=open(outputfilename,"w")
	for line in inputfile.readlines():
		data=line;
                data=data.replace("xx.log",str(db)+"_"+str(nextnum)+".log")

		if nextnum >=0 and nextnum <=9:
			data=data.replace("TDBxx","TDB0"+str(nextnum))
		if nextnum >=0 and nextnum <=7:
			data=data.replace("pdbxx","pdb01")
		if nextnum >=8 and nextnum <=15:
			data=data.replace("pdbxx","pdb05")
		if nextnum >=16 and nextnum <=23:
			data=data.replace("pdbxx","pdb02")
		if nextnum >=24 and nextnum <= 31:
			data=data.replace("pdbxx","pdb06")
		if nextnum >=32 and nextnum <=39:
			data=data.replace("pdbxx","pdb03")
		if nextnum >=40 and nextnum <=47:
			data=data.replace("pdbxx","pdb07")
		if nextnum >=48 and nextnum <=55:
			data=data.replace("pdbxx","pdb04")
		if nextnum >=56 and nextnum <=63:
			data=data.replace("pdbxx","pdb08")
	        data=data.replace("xx",str(nextnum));
                outputfile.write(data);
	outputfile.close()
	nextnum = nextnum + 1
	count = count + 1
	inputfile.close()
