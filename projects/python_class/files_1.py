#!/usr/bin/python

# fname = raw_input("Enter file name (words.txt) : ")
fname = 'words.txt'

hfile = open(fname)

for this_line in hfile :
    print this_line.rstrip().upper()
