package ki;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

import javax.management.RuntimeErrorException;

import ch.unibe.iam.graph.Edge;
import ch.unibe.iam.graph.Graph;
import ch.unibe.iam.graph.Vertex;

public class GraphSearch implements IGraphSearch {
	class NoSolutionException extends RuntimeException { private static final long serialVersionUID = -4347698144010546588L; }
	class NoStartVertex extends Exception {  }
	class NoEndVertex extends Exception {  }
	class RandomComparator implements Comparator<Vertex> {
		private Random random;
		public RandomComparator() {
			this.random = new Random();
		}
		@Override
		public int compare(Vertex o1, Vertex o2) {
			if (o1 == o2) return 0;
			if (o1 == null) return -1;
			if (o1.equals(o2)) return 0;
			return this.random.nextInt(2)*2-1;
		}
	}
	
	class HeuristicComparator implements Comparator<Vertex> {
		private Vertex base;
		public HeuristicComparator(Vertex v) {
			this.base = v;
		}
		@Override
		public int compare(Vertex a, Vertex b) {
			return d(a).compareTo(d(b));
		}
		
		private Float d(Vertex a) {
			float ax = (Float) a.getAttribute("x");
			float ay = (Float) a.getAttribute("y");
			
			float basex = (Float) base.getAttribute("x");
			float basey = (Float) base.getAttribute("y");
			
			float dx = ax-basex;
			float dy = ay-basey;
			return dx*dx+dy*dy;
		}
		
	}

	private Graph graph;
	private Vertex[] solution; ///< Path
	private Map<Vertex,Vertex> path;
	private Map<Vertex, Float> cost;
	
	public GraphSearch() {
		this.path = new HashMap<Vertex,Vertex>();
		this.cost = new HashMap<Vertex,Float>();
	}

	@Override
	public void setSearchGraph(Graph pSearchGraph) {
		this.graph = pSearchGraph;
	}

	@Override
	public void search() throws NoEndVertex, NoStartVertex {
		Vertex goal = goalVertex();
		Comparator<Vertex> comp = new HeuristicComparator(goal);
		SortedSet<Vertex> open = new TreeSet<Vertex>(comp);
		Vertex start = startVertex();
		open.add(start);
		cost.put(start, new Float(0));
		Set<Vertex> closed = new TreeSet<Vertex>(comp);
		while (!open.isEmpty()) {
			Vertex current = open.first();
			open.remove(current);
			if (current == null) continue;
			
			if (isGoalVertex(current)) {
				backtrace(current);
				return;
			}
			for (Vertex v : getAdjacent(current)) {
				if (closed.contains(v) || v == null) continue;
				float potentialCost = cost.get(current) + getCost(current, v);
				if (!isParent(v, current)) {
					path.put(v, current);
					cost.put(v, potentialCost);
					open.add(v);
				}
				else if (cost.get(v) > potentialCost) {
					path.put(v, current);
					cost.put(v, potentialCost);
					open.add(v);
				}
			}
		}
		throw new NoSolutionException();
	}

	private void backtrace(Vertex current) {
		ArrayList<Vertex> list = new ArrayList<Vertex>();
		do {
			list.add(current);
			current = path.get(current); 
		} while ( current != null);
		Vertex[] t = new Vertex[1];
		this.solution = list.toArray(t);
	}

	public List<Vertex> getAdjacent(Vertex v) {
		List<Vertex> adjacents = new LinkedList<Vertex>();
		for (Vertex o : graph.getVerticesArray()) {
			if (graph.areAdjacent(v, o))
				adjacents.add(o);
		}
		return adjacents;
	}
	
	public boolean isParent(Vertex parent, Vertex child) {
		if (child == null || parent == null) 
			return false;
		if (parent.equals(path.get(child)))
			return true;
		else 
			return isParent(parent, path.get(child));
	}

	@Override
	public Vertex[] getSolution() throws NoEndVertex, NoStartVertex {
		if (this.solution == null)
			search();
		return this.solution;
	}
	
	private Vertex startVertex() throws NoStartVertex {
		for (Vertex v : graph.getVerticesArray()) {
			if (isStartVertex(v))
				return v;
		}
		throw new NoStartVertex();
	}
	
	private Vertex goalVertex() throws NoEndVertex {
		for (Vertex v : graph.getVerticesArray()) {
			if (isGoalVertex(v)) {
				return v;
			}
		}
		throw new NoEndVertex();
	}
	
	private boolean isStartVertex(Vertex pVertex) {
	    Object curAttrib = pVertex.getAttribute("isStart");
	    if (curAttrib != null) {
	      if (curAttrib instanceof Boolean) {
	        return ((Boolean) curAttrib).booleanValue();
	      }
	    }
	    return false;
	  }

	private boolean isGoalVertex(Vertex pVertex) {
	    Object curAttrib = pVertex.getAttribute("isGoal");
	    if (curAttrib != null) {
	      if (curAttrib instanceof Boolean) {
	        return ((Boolean) curAttrib).booleanValue();
	      }
	    }
	    return false;
	  }
	
	private float getCost(Vertex a, Vertex b) {
		Edge edge = null;
		for (Edge e : graph.getEdgesArray()) {
			if (e.getTailVertex().equals(b) && e.getTailVertex().equals(a)) {
				edge = e;
			}
		}
		if (edge == null)
			return Float.POSITIVE_INFINITY;
	    Float curAttrib = (Float) edge.getAttribute("gewicht");
	    if (curAttrib != null) {
	      if (curAttrib instanceof Float) {
	        return ((Float) curAttrib).floatValue();
	      }
	    }
	    return Float.POSITIVE_INFINITY;
	  }
}
