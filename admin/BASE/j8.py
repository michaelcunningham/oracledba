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
suffix=suffix.replace("STAGEmeetme","spdb")
suffix=suffix.replace("spdb","spdb")
suffix=suffix.replace("PRODpdbs","pdb")
suffix=suffix.replace("PRODmeetme","mmdb")
count = 1
nextnum = 0
fname=inputfilename
fname=fname.replace("pxx","xx")

outfilename1=fname.replace("xx",str(suffix)+"01")
outfilename2=fname.replace("xx",str(suffix)+"02")
outfilename3=fname.replace("xx",str(suffix)+"03")
outfilename4=fname.replace("xx",str(suffix)+"04")
outfilename5=fname.replace("xx",str(suffix)+"05")
outfilename6=fname.replace("xx",str(suffix)+"06")
outfilename7=fname.replace("xx",str(suffix)+"07")
outfilename8=fname.replace("xx",str(suffix)+"08")

outfile1=open(outfilename1,"w")
outfile2=open(outfilename2,"w")
outfile3=open(outfilename3,"w")
outfile4=open(outfilename4,"w")
outfile5=open(outfilename5,"w")
outfile6=open(outfilename6,"w")
outfile7=open(outfilename7,"w")
outfile8=open(outfilename8,"w")
count = 0
while count < 64:
	inputfile = open(inputfilename,"r")
	for line in inputfile.readlines():
		data=line;
		data=data.replace("xx.log",str(db)+"_"+str(nextnum)+".log")
	        data=data.replace("xx",str(nextnum));
		if nextnum >=0 and nextnum <=7:
			data=data.replace("pdbxx","pdb01")
                	outfile1.write(data);
		if nextnum >=8 and nextnum <=15:
			data=data.replace("pdbxx","pdb05")
                	outfile5.write(data);
		if nextnum >=16 and nextnum <=23:
			data=data.replace("pdbxx","pdb02")
                	outfile2.write(data);
		if nextnum >=24 and nextnum <= 31:
			data=data.replace("pdbxx","pdb06")
                	outfile6.write(data);
		if nextnum >=32 and nextnum <=39:
			data=data.replace("pdbxx","pdb03")
                	outfile3.write(data);
		if nextnum >=40 and nextnum <=47:
			data=data.replace("pdbxx","pdb07")
                	outfile7.write(data);
		if nextnum >=48 and nextnum <=55:
			data=data.replace("pdbxx","pdb04")
                	outfile4.write(data);
		if nextnum >=56 and nextnum <=63:
			data=data.replace("pdbxx","pdb08")
                	outfile8.write(data);
	nextnum = nextnum + 1
	count = count + 1
	inputfile.close()
outfile1.close()
outfile2.close()
outfile3.close()
outfile4.close()
outfile5.close()
outfile6.close()
outfile7.close()
outfile8.close()
