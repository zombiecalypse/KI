#!/usr/bin/python

# Filename: f1.py
# Author:   Aaron Karper
# Created:  2011-10-03
# Description:
#          F1 optimal race 
import functools
def memoize(f):
	__mem__ = dict()
	@wraps(f)
	def x(arg):
		if __mem__.haskey(arg):
			return arg
		else:
			val = f(arg)
			__mem__[arg] = val
			return val
	return x

def training(gc, tc):
  return [[95, 96, 99, 104, 120],
   [94, 95, 97, 102, 108],
   [92, 93, 94, 98, 105],
   [91, 92, 93, 97, 104],
   [89, 90, 92, 95, 104]][tc][gc]

def runTime(filledFor):
	time = 0
	for lap in range(filledFor):
		left = filledFor-i
		tankCategory, wheelCategory = left // 12, i // 12
		time += training(tankCategory, wheelCategory)
	return time

@memoize
def bestTime(rest, filledFor):
	if   rest == 0: return 0
	elif rest < 0: return None 

	return 15+15+12*10 + runTime(filledFor) +min( 
			bestTime(rest-fillFor, fillFor) 
			for fillFor in range(12,60,12) 
			if fillFor is not None)

if __name__ = '__main__':
	print "Best Time:"
	print "%20s" % min(bestTime(60,i) for i in [60,48,36,24,12])
