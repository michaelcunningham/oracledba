s_score = raw_input( "Enter the score to be graded between 0 and 1 (example 0.872): " )
n_score = float( s_score )

if n_score > 1 :
	print '\n\tYou entered number which is too high. Try again\n'
elif n_score >= 0.90 :
	print 'A'
elif n_score >= 0.80 :
	print 'B'
elif n_score >= 0.70 :
	print 'C'
elif n_score >= 0.60 :
	print 'D'
else :
	print 'F'

print 42 % 10
