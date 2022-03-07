import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class astar_run {

    public static void main(String[] args) {
        astar astar = new astar();

        Node start = new Node(3);
        start.distanceToStartNode = 0;

        Node n1 = new Node(2);
        Node n2 = new Node(6);
        Node n3 = new Node(2);
        Node n4 = new Node(5);
        Node n5 = new Node(7);
        Node n6 = new Node(1);
        Node n7 = new Node(3);
        Node n8 = new Node(9);
        Node n9 = new Node(8);
        Node target = new Node(0);

        start.addEdge(n1, 1);
        start.addEdge(n2, 5);
        start.addEdge(n4, 3);
        n1.addEdge(n2, 1);
        n1.addEdge(n4, 1);
        n2.addEdge(n3, 2);
        n2.addEdge(n4, 7);
        n2.addEdge(n5, 4);
        n3.addEdge(n2, 2);
        n3.addEdge(n5, 5);
        n3.addEdge(n6, 8);
        n3.addEdge(n8, 4);
        n4.addEdge(start, 2);
        n4.addEdge(n1, 1);
        n4.addEdge(n3, 6);
        n4.addEdge(n5, 1);
        n5.addEdge(n7, 5);
        n6.addEdge(n8, 2);
        n6.addEdge(n9, 3);
        n7.addEdge(n3, 1);
        n7.addEdge(target, 3);
        n8.addEdge(n7, 3);
        n8.addEdge(n9, 2);
        n8.addEdge(target, 1);
        n9.addEdge(n7, 1);
        n9.addEdge(target, 5);

        printPath(astar.run(start, target));
    }

    public static void printPath(Node target) {
        if (target == null) {
            return;
        }
    
        List<Integer> ids = new ArrayList<Integer>();
    
        while (target.parent != null) {
            ids.add(target.id);
            target = target.parent;
        }
        ids.add(target.id);
        Collections.reverse(ids);
    
        for (int id : ids) {
            System.out.print(id + " ");
        }
        System.out.println("");
    }    
}