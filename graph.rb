require 'timeout'
include Timeout
class Float
	def self.inf
		1.0/0
	end
end

class Graph
	# list of symbols/names of cities
	attr_reader :nodes
	# hash signifying the connections
	attr_reader :edges
	def initialize nodes
		@nodes = nodes
		@edges = Hash.new
		@nodes.each {|e| @edges[e] = Hash.new}
	end
	def cons node1, node2, value
		@edges[node1][node2] = value
		@edges[node2][node1] = value
	end
	def value node1, node2
		return 0 if node1 == node2
		return Float.inf if  @edges[node1][node2].nil?
		@edges[node1][node2]
	end
	def self.readFromFile filename
		txtlines = open(filename).readlines
		n = txtlines[0].strip.to_i
		nodes = symbols n
		g = Graph.new(nodes)
		mat = txtlines.drop(1).collect do |row|
			row.split.collect {|e| e.to_i}
		end
		mat.each_with_index do |row, y|
			row.each_with_index do |cost, x|
				g.cons nodes[x], nodes[x+y], cost
			end
		end
		g
	end

	def connections v
		@edges[v].select {|e| e!= Float.inf}
	end

	def route aRoute
		return aRoute.cost if aRoute.respond_to? :cost
		here = aRoute[0]
		aRoute.drop(1).inject(0) do |number, node|
			adding = value here, node
			number += adding
			here = node
			number
		end
	end
	# Calculate the shortest path by trying each and every possible
	# route. This is O(n!).
	def naiveShortest
		car = @nodes.first
		cdr = @nodes.drop 1
		myroute = [car]+ cdr.permutation.min_by {|e| self.route [car]+e}
		r=Route.new self
		r.route = myroute
		r.cost =route(myroute)
		r
	end

	# Calculates the shortest path by excluding impossible combinations
	# from further examination (estimate and drop if route worse than best).
	def branchAndBoundShortest
		BrancherAndBounder.new(self).run
	end

	# Calculates a short path by being greedy. This is O(n²)
	def greedyShortest
		greedyRecur @nodes.drop(1), @nodes.first
	end

	def greedyRecur rest, here, aRoute=nil
		aRoute = Route.new(self) if aRoute.nil?
		return aRoute.add(here) if rest.empty?
		next_visit, cost = minCon(aRoute, here)
		rest.delete next_visit
		greedyRecur rest, next_visit, aRoute.add(here)
	end

	def minCon aRoute, station
		@edges[station].min_by do 
			|key, value| 
			if aRoute.rest.include? key
				value
			else
				Float.inf
			end
		end
	end


end

class AStar < Graph
	attr_accessor :start, :goal, :estimates
	def initialize nodes, est
		super nodes
		@estimates = est
	end
	def self.readFromFile fl
		raise "Filename needed" if fl.nil?
		lines = open(fl) {|f| f.readlines}
		airlineLines = lines.take_while {|e| not e.strip.empty?}
		connectionLines = lines.drop_while{|e| not e.strip.empty?} .drop(1)
		estimates = Hash.new
		for line in airlineLines
			name, air = line.split
			sname = name.to_sym
			start = sname
			goal ||= sname
			estimates[sname] = air.to_i
		end
		g = AStar.new estimates.keys, estimates
		g.start = start
		g.goal = goal
		for line in connectionLines
			from, to, cost = line.split
			sfrom, sto =from.to_sym, to.to_sym
			g.cons(sfrom, sto, cost.to_i)
		end
		g
	end

	def to_s
		"<AStar #{start} => #{goal}>"
	end

	def estimateFrom k
		@estimates[k]
	end

	def findRoute # A STAR
		raise "Goal not set" if goal.nil?
		raise "Start not set" if start.nil?
		open = [start]
		closed = []
		route = Route.new(self)
		current = start
		while open != []
			current = open.min_by {|e| estimateFrom(e) + self.value(current,e)}
			route = route.add(current)
			return route if current == goal
			closed << open.delete(current)
			open += (connections(current).keys-closed)
		end
		raise "No Route found"
	end
end

class Route
	attr_accessor :cost, :route, :rest
	def initialize graph
		@graph = graph
		@rest = graph.nodes
		@cost = 0
		@route = []
	end
	def clone
		newRoute = Route.new @graph
		newRoute.route = route.clone
		newRoute.rest = rest.clone
		newRoute.cost = cost
		newRoute
	end
	def add station
		newRoute = clone
		newRoute.cost += @graph.value route.last, station if not @route.empty?
		newRoute.route << station
		newRoute.rest.delete(station)
		newRoute
	end
	def to_s
		"#{(route.collect{|e| e.to_s}).join " => "} (#{cost})"
	end

	def greedyRecur
		return self if rest.empty?
		lowestCost = rest.min_by {|e| @graph.value @route.last, e}
		add(lowestCost).greedyRecur
	end
end

class BrancherAndBounder
	def initialize graph
		@graph = graph
		@routes = [Route.new(@graph).add(@graph.nodes[0])]
		@lowerbound = - Float.inf
		@upperbound = Float.inf
	end

	def estimateHigh route
		est = route.greedyRecur
		est.cost
	end

	def estimateLow route
		cost = route.cost
		for node in route.rest
			nnode,mincost = @graph.edges[node].min_by {|e,f| f}
			cost += mincost
		end
		cost
	end

	def iterate_routes
		newRoutes = []
		@routes = @routes.select {|e| go_on? e}
		for route in @routes
			for station in route.rest
				newRoutes << (route.add station)
			end
		end
		#puts (newRoutes.collect {|e| "hi: #{estimateHigh(e)}\nlo: #{estimateLow(e)}\n r:  #{e.to_s}"})
		#puts "--------"
		newRoutes.each {|e| update_bounds route}
		newRoutes
	end

	# Is there still hope to be the fastest route?
	def go_on? route
		route.rest.size==1 or (estimateLow(route) <= @upperbound and not route.rest.empty?)
	end

	def update_bounds route
		@upperbound = [estimateHigh(route), @upperbound].min
		@lowerbound = [estimateLow(route), @lowerbound].max
	end

	def run
		iterate_routes
		while @routes.any? {|e| go_on? e}
			@routes = iterate_routes
		end
		@routes.min_by {|e| e.cost}
	end
end

def symbols n
	1.upto(n).collect {|e| :"s#{e}"}
end

def time name
	t0 = Time.now
	result = yield
	t1 = Time.now
	delta = t1-t0
	puts "#{name}: #{delta}s"
	[result, delta]
end

puts AStar.readFromFile(ARGV[0]).findRoute
