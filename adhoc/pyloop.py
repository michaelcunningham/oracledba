#!/usr/bin/python

import time

x = 0
n_start = time.time()

for i in range(10000000):
	x

print "seconds = %f" % float(time.time() - n_start)

x = 0
n_start = time.time()

while x <= 10000000:
	x += 1

print "seconds = %f" % float(time.time() - n_start)
