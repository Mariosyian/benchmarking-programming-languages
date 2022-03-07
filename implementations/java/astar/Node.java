import java.util.ArrayList;

/**
 * Represents a standalone node of a graph.
 */
public class Node implements Comparable<Node> {
    private static int idCounter = 0;
    public int id;

    public Node parent = null;

    public ArrayList<Edge> neighbours;

    // Evaluation functions
    public double costOfNode = Double.MAX_VALUE;
    public double distanceToStartNode = Double.MAX_VALUE;

    public double heuristic; 

    public Node(double heuristic) {
        this.heuristic = heuristic;
        this.id = idCounter++;
        this.neighbours = new ArrayList<Edge>();
    }

    public void addEdge(Node node, int weight) {
        neighbours.add(new Edge(node, weight));
    }
    
    public double getHeuristic() {
        return this.heuristic;
    }

    public boolean equals(Node node) {
        return this.id == node.id;
    }
 
    @Override
    public int compareTo(Node node) {
        return Double.compare(this.costOfNode, node.costOfNode);
    }
}
