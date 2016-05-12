#!/usr/bin/python

text = "X-DSPAM-Confidence:    0.8475";
snum = text[text.find(' '):].strip()
num = float( snum )
print num
