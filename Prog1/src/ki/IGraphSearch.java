
package ki;

import ki.GraphSearch.NoEndVertex;
import ki.GraphSearch.NoStartVertex;
import ch.unibe.iam.graph.Graph;
import ch.unibe.iam.graph.Vertex;

/**
 * einfaches Interface f�r eine Graphsuche.
 * WICHTIG: der implementiert Suchalgorithmus
 * soll dieses Interface einhalten! Ausserdem
 * soll er ebenfalls im Package "ki" sein.
 */
public interface IGraphSearch {

  /**
   * Sets the graph to be searched. The graph can either be directed or
   * undirected.
   * 
   * @param pSearchGraph the graph to be searched
   */
  public void setSearchGraph(Graph pSearchGraph);
  
  /**
   * search a path in the searchgraph, from start- to goalnode.
 * @throws NoEndVertex 
 * @throws NoStartVertex 
   *
   */
  public void search() throws NoEndVertex, NoStartVertex;
  
  /**
   * Returns the result of the search, specified through an array of vertices.
   * result[0] is equal to the start vertex, result[result.length] is equal to
   * the goal vertex.
   * 
   * @return Vertex[] result, an ordered array of vertices specifying the path
   *         to the result.
 * @throws NoStartVertex 
 * @throws NoEndVertex 
   */
  public Vertex[] getSolution() throws NoEndVertex, NoStartVertex;
  
}
