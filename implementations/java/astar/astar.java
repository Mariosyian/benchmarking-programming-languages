import java.util.ArrayList;
import java.util.PriorityQueue;

/**
 * Example code for implementing the A-Star algorithm.
 *
 * The purpose of this program is to create a list of interconnected nodes (a graph),
 * and then take a `start` and `target` node to calculate the shortest path between
 * them.
 *
 * @param start The node to start searching from.
 * @param target The node to find a path towards from `start`.
 *
 * @return The target node if found, the `null` value otherwise.
 * 
 * The path can be derived by visiting the `parent` node starting from the `target`
 * node, then reversing the resulting collection.
 *
 * @author Marios Yiannakou
 */
public class astar {
    /**
     * Given a start and finish node, derives the shortest path (if any) between them.
     * 
     * @param start The node to start searching from.
     * @param target The node to find a path towards from `start`.
     *
     * @return The target node if found, the `null` value otherwise.
     */
    public static Node run(Node start, Node target) {
        PriorityQueue<Node> finishedNodes = new PriorityQueue<Node>();
        PriorityQueue<Node> visitedNodes = new PriorityQueue<Node>();
    
        start.f = start.g + start.calculateHeuristic();
        visitedNodes.add(start);
    
        while (!visitedNodes.isEmpty()) {
            Node node = visitedNodes.peek();
            if (node.equals(target)) {
                return node;
            }

            for (Edge edge : node.neighbours) {
                Node neighbour = edge.node;
                double totalWeight = node.g + edge.weight;
    
                if (!visitedNodes.contains(neighbour) && !finishedNodes.contains(neighbour)) {
                    neighbour.parent = node;
                    neighbour.g = totalWeight;
                    neighbour.f = neighbour.g + neighbour.calculateHeuristic();
                    visitedNodes.add(neighbour);
                } else {
                    if (totalWeight < neighbour.g) {
                        neighbour.parent = node;
                        neighbour.g = totalWeight;
                        neighbour.f = neighbour.g + neighbour.calculateHeuristic();
    
                        if (finishedNodes.contains(neighbour)) {
                            finishedNodes.remove(neighbour);
                            visitedNodes.add(neighbour);
                        }
                    }
                }
            }

            visitedNodes.remove(node);
            finishedNodes.add(node);
        }

        return null;
    }
}
