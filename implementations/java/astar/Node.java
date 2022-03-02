import java.util.ArrayList;
import java.util.List;

/**
 * Represents a standalone node of a graph.
 */
public class Node implements Comparable<Node> {
    private static int idCounter = 0;
    public int id;

    public Node parent = null;

    public ArrayList<Edge> neighbours;

    // Evaluation functions
    public double f = Double.MAX_VALUE;
    public double g = Double.MAX_VALUE;

    public double heuristic; 

    public Node(double heuristic) {
        this.heuristic = heuristic;
        this.id = idCounter++;
        this.neighbours = new ArrayList<Edge>();
    }

    public void addEdge(int weight, Node node) {
        neighbours.add(new Edge(weight, node));
    }
    
    public double calculateHeuristic() {
        return this.heuristic;
    }

    public boolean equals(Node node) {
        return this.id == node.id;
    }

    public Node getNode() {
        return this;
    }
 
    @Override
    public int compareTo(Node node) {
        return Double.compare(this.f, node.f);
    }
}
