#!/usr/bin/python

# Filename: f1.py
# Author:   Aaron Karper
# Created:  2011-10-03
# Description:
#          F1 optimal race 
from functools import wraps
def memoize(f):
	"assumes f is pure and keywords don't matter"
	__mem__ = dict()
	@wraps(f)
	def x(*args, **kargs):
		if not args in __mem__:
			__mem__[args] = f(*args, **kargs)
		return __mem__[args]
	return x

def training(gc, tc):
	try:
		return [[95, 96, 99, 104, 120],
		 [94, 95, 97, 102, 108],
		 [92, 93, 94, 98, 105],
		 [91, 92, 93, 97, 104],
		 [89, 90, 92, 95, 104]][tc][gc]
	except IndexError:
		raise IndexError("(%s %s) is out of range" % (gc, tc))

def runTime(filledFor):
	time = 0
	for lap in range(filledFor):
		left = filledFor-lap
		tankCategory, wheelCategory = (left-1) // 12, (lap-1) // 12
		time += training(tankCategory, wheelCategory)
	return time

@memoize
def bestTime(rest, filledFor, runs = []):
	if   rest == 0: return (0, runs)
	elif rest < 0: return (None, runs)

	return min( [(15+15+12*10+i+ runTime(filledFor), r) for i,r in 
						[bestTime(rest-fillFor, fillFor, runs = [fillFor]+runs) for fillFor in range(12,60,12) ]
						if i is not None], key = lambda x: x[0])

if __name__ == '__main__':
	print "Best Time:"
	print "%20s%20s" % min([i for i in map( lambda x: bestTime(60,x),[60,48,36,24,12]) if i is not None], key = lambda x: x[0])
