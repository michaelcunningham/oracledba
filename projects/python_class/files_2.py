#!/usr/bin/python

fname = raw_input("Enter file name (mbox-short.txt) : ")

hfile = open(fname)

line_count = 0
total = 0

for this_line in hfile :
    if this_line.startswith("X-DSPAM-Confidence:") :
        snum = this_line[this_line.find(' '):].strip()
        num = float( snum )
        line_count += 1
        total += num
total_avg = total / line_count

print "Average spam confidence: " + str( total_avg )
