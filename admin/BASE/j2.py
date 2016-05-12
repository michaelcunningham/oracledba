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

count = 0
nextnum = 0
fname=inputfilename
fname=fname.replace("pxx","xx")

outfilename1=fname.replace("xx",str(suffix)+"01")
fname=inputfilename
outfilename2=fname.replace("xx",str(suffix)+"02")

outfile1=open(outfilename1,"w")
outfile2=open(outfilename2,"w")

while count < 64:
	inputfile = open(inputfilename,"r")
	for line in inputfile.readlines():
		data=line;
		data=data.replace("xx.log",str(db)+"_"+str(nextnum)+".log")
	        data=data.replace("xx",str(nextnum));
		#if there are any db links to get data from pdbs
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

		# split into two output files
		if nextnum >=0 and nextnum <=31:
			data=data.replace("mmdbxx","mmdb01")
                	outfile1.write(data);
		if nextnum >=8 and nextnum <=64:
			data=data.replace("mmdbxx","mmdb02")
                	outfile2.write(data);
	nextnum = nextnum + 1
	count = count + 1
	inputfile.close()
outfile1.close()
outfile2.close()
