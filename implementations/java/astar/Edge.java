/**
 * Represents the encapsulation of a `Node` with a weight, so it can be represented
 * as a connected component with a heuristic in a graph. 
 */
public class Edge {
    public int weight;
    public Node node;
    
    public Edge(Node node, int weight) {
        this.node = node;
        this.weight = weight;
    }
}
